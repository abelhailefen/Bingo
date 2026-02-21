using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Hubs;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Concurrent;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Bingo.Core.Services;

public class RoomManagerService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly IHubContext<BingoHub> _hubContext;
    private readonly ILogger<RoomManagerService> _logger;
    
    // Track active bot joining tasks per room
    private readonly ConcurrentDictionary<long, CancellationTokenSource> _botJoiningTasks = new();

    public RoomManagerService(
        IServiceProvider serviceProvider, 
        IHubContext<BingoHub> hubContext,
        ILogger<RoomManagerService> logger)
    {
        _serviceProvider = serviceProvider;
        _hubContext = hubContext;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            using (var scope = _serviceProvider.CreateScope())
            {
                var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
                var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();
                
                // 1. Check for rooms in waiting status that need bot joining to start
                var waitingRooms = await repo.FindAsync<Room>(r => r.Status == RoomStatusEnum.Waiting);
                foreach (var room in waitingRooms)
                {
                    // Start gradual bot joining if not already started
                    if (!_botJoiningTasks.ContainsKey(room.RoomId))
                    {
                        var cts = new CancellationTokenSource();
                        _botJoiningTasks[room.RoomId] = cts;
                        
                        _ = Task.Run(async () =>
                        {
                            await StartGradualBotJoiningAsync(room.RoomId, cts.Token);
                        }, cts.Token);
                        
                        _logger.LogInformation("Started gradual bot joining for room {RoomId}", room.RoomId);
                    }
                }

                // 2. Get all rooms ready to start (countdown reached)
                var pendingRooms = await repo.FindAsync<Room>(r =>
                    r.Status == RoomStatusEnum.Waiting && r.ScheduledStartTime <= DateTime.UtcNow);

                foreach (var room in pendingRooms)
                {
                    // CHECK: Is there already a game IN PROGRESS for this specific price?
                    bool priceIsBusy = await repo.AnyAsync<Room>(r =>
                        r.CardPrice == room.CardPrice &&
                        r.Status == RoomStatusEnum.InProgress);

                    if (priceIsBusy)
                    {
                        // Just notify the lobby and wait - don't push the timer forward
                        // This prevents countdown from jumping artificially to 3 minutes!
                        await _hubContext.Clients.Group(room.RoomId.ToString())
                            .SendAsync("WaitingForPreviousGame", room.RoomId);

                        continue; // Skip starting this room for now, keep checking
                    }

                    // No active game for this price? Start immediately!
                    // Cancel any ongoing bot joining task for this room
                    if (_botJoiningTasks.TryRemove(room.RoomId, out var cts))
                    {
                        cts.Cancel();
                        cts.Dispose();
                    }

                    // Start the game
                    room.Status = RoomStatusEnum.InProgress;
                    room.StartedAt = DateTime.UtcNow;
                    await repo.UpdateAsync(room);
                    await repo.SaveChanges();

                    await _hubContext.Clients.Group(room.RoomId.ToString())
                        .SendAsync("GameStarted", room.RoomId);
                        
                    _logger.LogInformation("Game started for room {RoomId}", room.RoomId);
                }

                // 3. Call numbers for active rooms
                var activeRooms = await repo.FindAsync<Room>(r => r.Status == RoomStatusEnum.InProgress);
                foreach (var room in activeRooms)
                {
                    // Logic: call a number command
                    await mediator.Send(new CallNumberCommand(room.RoomId), stoppingToken);
                }
            }

            // Frequency of the loop
            await Task.Delay(5000, stoppingToken);
        }
    }

    /// <summary>
    /// Gradually adds bots to a room during the countdown period
    /// </summary>
    private async Task StartGradualBotJoiningAsync(long roomId, CancellationToken ct)
    {
        try
        {
            List<User> assignedBots;
            double intervalMs;

            // --- STEP 1: INITIAL SETUP (Query DB Only Once) ---
            using (var scope = _serviceProvider.CreateScope())
            {
                var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
                var botService = scope.ServiceProvider.GetRequiredService<BotPlayerService>();

                var room = await repo.FindOneAsync<Room>(r => r.RoomId == roomId);
                if (room == null || room.Status != RoomStatusEnum.Waiting || !room.ScheduledStartTime.HasValue)
                    return;

                var countdownSeconds = (room.ScheduledStartTime.Value - DateTime.UtcNow).TotalSeconds - 7.0;
                if (countdownSeconds <= 0) countdownSeconds = 1; // Fallback for very tight starts

                // Count real players efficiently
                var realPlayerCount = await repo.CountAsync<RoomPlayer>(rp => rp.RoomId == roomId);

                int requiredBotCount = botService.GetRequiredBotCount(realPlayerCount, room.CardPrice);
                if (requiredBotCount <= 0) return;

                // Fetch the list of bots once. We don't check DB again after this.
                assignedBots = await botService.GetBotsForRoomAsync(roomId, requiredBotCount);

                // Calculate timing
                intervalMs = Math.Max(5, (countdownSeconds * 1000) / assignedBots.Count);

                _logger.LogInformation("Room {RoomId}: Spawning {BotCount} bots every {Interval}ms",
                    roomId, assignedBots.Count, (int)intervalMs);
            }

            // --- STEP 2: THE JOINING LOOP ---
            for (int i = 0; i < assignedBots.Count; i++)
            {
                // CRITICAL CHECK: This is how it knows the game started.
                // If the main ExecuteAsync loop calls cts.Cancel(), this loop breaks instantly.
                if (ct.IsCancellationRequested) break;

                var currentBot = assignedBots[i];

                // Fire-and-forget the actual DB insertion
                _ = Task.Run(async () =>
                {
                    // Double check before creating scope/hitting DB
                    if (ct.IsCancellationRequested) return;

                    try
                    {
                        using var loopScope = _serviceProvider.CreateScope();
                        var botService = loopScope.ServiceProvider.GetRequiredService<BotPlayerService>();

                        // Note: Ideally, AddSpecificBotToRoomAsync should accept the 'ct' 
                        // to cancel the SQL INSERT itself if the game starts mid-query.
                        await botService.AddSpecificBotToRoomAsync(roomId, currentBot);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Bot {BotId} failed to join Room {RoomId}", currentBot.UserId, roomId);
                    }
                }, ct);

                // Wait the calculated interval before the next bot
                // If ct is cancelled during this delay, Task.Delay throws OperationCanceledException
                // which is caught by the catch block below, ending the method.
                await Task.Delay((int)intervalMs, ct);
            }

            _logger.LogInformation("Gradual bot joining finished for room {RoomId}", roomId);
        }
        catch (OperationCanceledException)
        {
            // This is the "Clean Exit". It means ExecuteAsync triggered the cancellation.
            _logger.LogInformation("Bot joining for room {RoomId} halted because game started.", roomId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in StartGradualBotJoiningAsync for room {RoomId}", roomId);
        }
    }
}