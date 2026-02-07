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
                // Ensure bots are added right before game starts
                await AddBotsToRoom(roomId, repo);

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

                    // Check if any bots won
                    await CheckBotWins(roomId, repo, mediator);

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

    private async Task AddBotsToRoom(long roomId, IBingoRepository repo)
    {
        var room = await repo.GetActiveRoomWithPlayersAsync(roomId);
        if (room == null) return;

        int currentPlayerCount = room.Players.Count;
        if (currentPlayerCount >= 5) return; // Enough real players

        int botsNeeded = 5 - currentPlayerCount;
        var existingBots = await repo.FindAsync<User>(u => u.Username.StartsWith("Bot-"));
        
        // Create matching bot users if they don't exist
        for (int i = 1; i <= botsNeeded; i++)
        {
            string botName = $"Bot-{Guid.NewGuid().ToString().Substring(0, 5)}";
            var botUser = existingBots.FirstOrDefault(b => b.Username == botName); // Unlikely to match GUID but good practice
            
            if (botUser == null)
            {
                botUser = new User
                {
                    UserId = Math.Abs(Guid.NewGuid().GetHashCode()), // Simple ID generation
                    Username = botName,
                    PhoneNumber = $"000-{Math.Abs(Guid.NewGuid().GetHashCode())}", // Dummy phone
                    PasswordHash = "bot-hash",
                    Balance = 10000
                };
                try 
                {
                    // Check if ID exists (collision check)
                    if (await repo.FindOneAsync<User>(u => u.UserId == botUser.UserId) != null)
                        botUser.UserId = Math.Abs(Guid.NewGuid().GetHashCode());

                     await repo.AddAsync(botUser);
                     await repo.SaveChanges();
                }
                catch 
                { 
                     // Creation failed (likely concurrency or collision). 
                     // Try to fetch existing bot with this name in case another thread created it.
                     var existing = await repo.FindOneAsync<User>(u => u.Username == botName);
                     if (existing != null)
                     {
                         botUser = existing;
                     }
                     else
                     {
                         // If we can't create or find it, skip this bot.
                         continue;
                     }
                }
            }

            // Join Room
             var roomPlayer = new RoomPlayer
            {
                RoomId = roomId,
                UserId = botUser.UserId,
                IsReady = true
            };
            
            if (!await repo.AnyAsync<RoomPlayer>(rp => rp.RoomId == roomId && rp.UserId == botUser.UserId))
            {
                await repo.AddAsync(roomPlayer);
                await repo.SaveChanges();
            }

            // Buy a Card
            // Pick a random MasterCard that isn't taken
            var takenMasterCardIds = await repo.GetTakenCardIdsAsync(roomId);
            var random = new Random();
            int masterCardId;
            do
            {
                masterCardId = random.Next(1, 101); // Assuming 100 master cards
            } while (takenMasterCardIds.Contains(masterCardId));

            await repo.PickMasterCardAsync(botUser.UserId, roomId, masterCardId);
        }
    }

    private async Task CheckBotWins(long roomId, IBingoRepository repo, IMediator mediator)
    {
        var room = await repo.FindOneAsync<Room>(r => r.RoomId == roomId);
        if (room == null || room.Status != RoomStatusEnum.InProgress) return;

        // Get Bot cards
        // Since we can't easily filter by "User.Username.StartsWith" in Join if not mapped, 
        // we'll get all cards and check in memory or better, get bot users first.
        // Optimization: Get users with "Bot-" then get their cards in this room.
        
        var botUsers = await repo.FindAsync<User>(u => u.Username.StartsWith("Bot-"));
        var botUserIds = botUsers.Select(u => u.UserId).ToList();

        if (!botUserIds.Any()) return;

        var cards = await repo.FindAsync<Card>(c => c.RoomId == roomId && botUserIds.Contains(c.UserId));

        foreach (var card in cards)
        {
            // Verify Win for the room's current pattern
            bool isWin = await repo.VerifyWinAsync(card.CardId, room.Pattern);
            if (isWin)
            {
                // Claim Win
                await mediator.Send(new ClaimWinCommand(roomId, card.UserId, card.CardId, (WinTypeEnum)room.Pattern));
                // We don't break here, allowing multiple bots to potentially win on the same number (though ClaimWin might end the game)
            }
        }
    }
}