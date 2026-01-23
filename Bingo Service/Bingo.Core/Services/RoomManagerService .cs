using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Hubs;
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

                    // 1. Find rooms that should have started
                    var expiredRooms = await repo.FindAsync<Room>(r =>
                        r.Status == RoomStatusEnum.Waiting &&
                        r.ScheduledStartTime <= DateTime.UtcNow);

                    foreach (var room in expiredRooms)
                    {
                        // 2. Change status to InProgress
                        room.Status = RoomStatusEnum.InProgress;
                        room.StartedAt = DateTime.UtcNow;

                        await repo.UpdateAsync(room);
                        await repo.SaveChanges();

                        // 3. Notify everyone in that Room via SignalR
                        await _hubContext.Clients.Group(room.RoomId.ToString())
                            .SendAsync("GameStarted", room.RoomId);
                    }
                }

                await Task.Delay(1000, stoppingToken); // Check every second
            }
        }
    }
}
