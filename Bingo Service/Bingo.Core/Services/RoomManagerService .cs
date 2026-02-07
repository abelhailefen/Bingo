using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Hubs;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Bingo.Core.Services;

public class RoomManagerService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly IHubContext<BingoHub> _hubContext;

    public RoomManagerService(IServiceProvider serviceProvider, IHubContext<BingoHub> hubContext)
    {
        _serviceProvider = serviceProvider;
        _hubContext = hubContext;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            using (var scope = _serviceProvider.CreateScope())
            {
                var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
                var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();

                // 1. Get all rooms waiting to start
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
                        // Someone is still playing a game at this price point.
                        // We push the start time forward by 10 seconds and notify the lobby.
                        room.ScheduledStartTime = DateTime.UtcNow.AddSeconds(10);
                        await repo.UpdateAsync(room);
                        await repo.SaveChanges();

                        await _hubContext.Clients.Group(room.RoomId.ToString())
                            .SendAsync("WaitingForPreviousGame", room.RoomId);

                        continue; // Skip starting this room for now
                    }

                    // No active game for this price? Start it!
                    room.Status = RoomStatusEnum.InProgress;
                    room.StartedAt = DateTime.UtcNow;
                    await repo.UpdateAsync(room);
                    await repo.SaveChanges();

                    await _hubContext.Clients.Group(room.RoomId.ToString())
                        .SendAsync("GameStarted", room.RoomId);
                }

                // 2. Call numbers for active rooms
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
}