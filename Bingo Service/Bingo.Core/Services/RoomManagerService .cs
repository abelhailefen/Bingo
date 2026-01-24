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
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Services
{
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

                    // 1. Start pending rooms
                    var pendingRooms = await repo.FindAsync<Room>(r =>
                        r.Status == RoomStatusEnum.Waiting && r.ScheduledStartTime <= DateTime.UtcNow);

                    foreach (var room in pendingRooms)
                    {
                        room.Status = RoomStatusEnum.InProgress;
                        room.StartedAt = DateTime.UtcNow;
                        await repo.UpdateAsync(room);
                        await repo.SaveChanges();
                        await _hubContext.Clients.Group(room.RoomId.ToString()).SendAsync("GameStarted", room.RoomId);
                    }

                    // 2. Call numbers for active rooms
                    var activeRooms = await repo.FindAsync<Room>(r => r.Status == RoomStatusEnum.InProgress);
                    foreach (var room in activeRooms)
                    {
                        // Simple logic: call a number every 5 seconds (roughly)
                        // In a production app, you'd track the 'LastCalledAt' property in the Room entity
                        await mediator.Send(new CallNumberCommand(room.RoomId));
                    }
                }
                await Task.Delay(5000, stoppingToken);
            }
        }
    }
}
