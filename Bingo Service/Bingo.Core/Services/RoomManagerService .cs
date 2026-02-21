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
            int requiredBotCount = 0;
            double intervalMs = 1000;
            List<User> assignedBots = new List<User>();

            // --- STEP 1: INITIAL CALCULATION ---
            // Use a temporary scope just to calculate how many bots we need
            using (var initialScope = _serviceProvider.CreateScope())
            {
                var repo = initialScope.ServiceProvider.GetRequiredService<IBingoRepository>();
                var botService = initialScope.ServiceProvider.GetRequiredService<BotPlayerService>();

                var room = await repo.FindOneAsync<Room>(r => r.RoomId == roomId);
                if (room == null || room.Status != RoomStatusEnum.Waiting || !room.ScheduledStartTime.HasValue)
                    return;

                var countdownSeconds = (room.ScheduledStartTime.Value - DateTime.UtcNow).TotalSeconds;
                if (countdownSeconds <= 0) return;

                // Count real players (non-bots)
                var allPlayers = await repo.FindAsync<RoomPlayer>(rp => rp.RoomId == roomId);
                int realPlayerCount = 0;
                foreach (var p in allPlayers)
                {
                    var user = await repo.FindOneAsync<User>(u => u.UserId == p.UserId);
                    if (user != null && !user.IsBot) realPlayerCount++;
                }

                requiredBotCount = botService.GetRequiredBotCount(realPlayerCount, room.CardPrice);
                if (requiredBotCount <= 0) return;

                // Pre-allocate all random bot queries upfront to avoid repeated Db queries!
                assignedBots = await botService.GetBotsForRoomAsync(roomId, requiredBotCount);
                requiredBotCount = assignedBots.Count;
                if (requiredBotCount <= 0) return;

                // Calculate timing: Target finishing 7 seconds early to comfortably beat the 5 second hard-cutoff
                // If the game is starting very soon, compress the interval down to 5ms so 70 threads can spawn in 350ms!
                var targetSeconds = Math.Max(1.0, countdownSeconds - 7.0);
                intervalMs = Math.Max(5, (targetSeconds * 1000) / requiredBotCount);

                _logger.LogInformation(
                    "Room {RoomId}: Planning {BotCount} bots over {Countdown}s (Interval: {Interval}ms)",
                    roomId, requiredBotCount, countdownSeconds, (int)intervalMs);
            }

            // --- STEP 2: THE JOINING LOOP ---
            // Use ONE scope for the entire bulk operation to eliminate overhead
            using (var loopScope = _serviceProvider.CreateScope())
            {
                var botService = loopScope.ServiceProvider.GetRequiredService<BotPlayerService>();
                
                // Do the giant bulk insert instantly (takes < 50ms)
                // The BotService will natively detached-spawn the SignalR spaced broadcast loop internally
                // so the user still sees them gradually arriving!
                int added = await botService.BulkAddBotsWithCardsAsync(roomId, assignedBots, intervalMs, ct);
                
                if (added < assignedBots.Count) {
                    _logger.LogWarning("Room {RoomId}: Bulk joined {Added}/{Planned} bots.", roomId, added, assignedBots.Count);
                }
            }

            _logger.LogInformation("Completed instantaneous bulk bot joining process for room {RoomId}", roomId);
        }
        catch (OperationCanceledException)
        {
            _logger.LogInformation("Bot joining task for room {RoomId} was cancelled (Game likely started).", roomId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during gradual bot joining for room {RoomId}", roomId);
        }
    }
}