using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Features.Gameplay.Contract.Service;
using Bingo.Core.Hubs;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
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
    private readonly IRoomManagerSignal _signal;

    private static readonly ConcurrentDictionary<decimal, SemaphoreSlim> _priceLocks = new();

    public RoomManagerService(IServiceProvider serviceProvider, IHubContext<BingoHub> hubContext,IRoomManagerSignal signal)
    {
        _serviceProvider = serviceProvider;
        _hubContext = hubContext;
        _signal = signal;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using (var scope = _serviceProvider.CreateScope())
        {
            var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
            var existingRooms = await repo.FindAsync<Room>(r => r.Status != RoomStatusEnum.Completed);
            foreach (var r in existingRooms)
                _ = Task.Run(() => ProcessRoomLifetime(r.RoomId, r.CardPrice, stoppingToken));
        }

        // 2. Event-driven: Wait for new room signals
        await foreach (var (roomId, cardPrice) in _signal.Reader.ReadAllAsync(stoppingToken))
        {
            // Fire and forget the room lifecycle handler so the loop can pick up the next signal
            _ = Task.Run(() => ProcessRoomLifetime(roomId, cardPrice, stoppingToken));
        }
    }
    private async Task ProcessRoomLifetime(long roomId, decimal cardPrice, CancellationToken ct)
    {
        // Get or create a lock specific to this price point (e.g., "10 Birr Lock")
        var priceLock = _priceLocks.GetOrAdd(cardPrice, _ => new SemaphoreSlim(1, 1));

        try
        {
            using var scope = _serviceProvider.CreateScope();
            var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
            var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();

            var room = await repo.FindOneAsync<Room>(r => r.RoomId == roomId);
            if (room == null || room.Status == RoomStatusEnum.Completed) return;

            DateTime scheduledTime = room.ScheduledStartTime ?? DateTime.UtcNow;
            TimeSpan delay = scheduledTime - DateTime.UtcNow;

            if (delay > TimeSpan.Zero)
            {
                
                await Task.Delay(delay, ct);
            }

            // STEP B: Queue for this price point (Wait if another game is running)
            bool notifiedWaiting = false;
            while (!await priceLock.WaitAsync(100, ct)) // Try to enter the lock
            {
                if (!notifiedWaiting)
                {
                    await _hubContext.Clients.Group(roomId.ToString()).SendAsync("WaitingForPreviousGame", roomId);
                    notifiedWaiting = true;
                }
                await Task.Delay(2000, ct); // Check lock availability every 2s
            }

            try
            {
                // STEP C: Start the Game
                room.Status = RoomStatusEnum.InProgress;
                room.StartedAt = DateTime.UtcNow;
                await repo.UpdateAsync(room);
                await repo.SaveChanges();
                await _hubContext.Clients.Group(roomId.ToString()).SendAsync("GameStarted", roomId);

                // STEP D: Game Loop (Calling Numbers)
                while (!ct.IsCancellationRequested)
                {
                    // Reload room to check status (if a winner was found by another process)
                    var currentRoom = await repo.FindOneAsync<Room>(r => r.RoomId == roomId);
                    if (currentRoom.Status == RoomStatusEnum.Completed) break;

                    await mediator.Send(new CallNumberCommand(roomId), ct);

                    // Interval between numbers (e.g., 5 seconds)
                    await Task.Delay(5000, ct);
                }
            }
            finally
            {
                priceLock.Release();
            }
        }
        catch (Exception ex)
        {
          Console.WriteLine($"Error processing room {roomId}: {ex.Message}");
        }
    }
}