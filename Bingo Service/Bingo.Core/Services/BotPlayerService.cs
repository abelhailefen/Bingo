using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Hubs;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Bingo.Core.Services;

public class BotPlayerService
{
    private readonly IBingoRepository _repository;
    private readonly IMediator _mediator;
    private readonly ILogger<BotPlayerService> _logger;
    private readonly IHubContext<BingoHub> _hubContext;
    private static readonly Random _random = new();

    // Maximum number of bots we'll ever create in the system
    // Increased to 250 to support multiple concurrent rooms with different wager types
    private const int MaxBotCount = 250;

    public BotPlayerService(
        IBingoRepository repository,
        IMediator mediator,
        ILogger<BotPlayerService> logger,
        IHubContext<BingoHub> hubContext)
    {
        _repository = repository;
        _mediator = mediator;
        _logger = logger;
        _hubContext = hubContext;
    }

    /// <summary>
    /// Calculate how many bots are needed based on real player count and room price
    /// </summary>
    public int GetRequiredBotCount(int realPlayerCount, decimal cardPrice)
    {
        // Explicitly enforce exactly 70 bots for the 5 and 10 ETB rooms
        if (cardPrice == 5m || cardPrice == 10m)
        {
            return Math.Max(0, 70 - realPlayerCount);
        }

        return realPlayerCount switch
        {
            1 => 50,
            >= 2 and <= 4 => 45,
            >= 5 and <= 9 => 40,
            >= 10 and <= 14 => 35,
            >= 15 and <= 19 => 30,
            >= 20 and <= 24 => 25,
            >= 25 and <= 29 => 20,
            >= 30 and <= 34 => 15,
            >= 35 and <= 39 => 10,
            >= 40 and <= 44 => 5,
            _ => 0 // 45+ players, no bots needed
        };
    }

    /// <summary>
    /// Ensure bot users exist in the database (create if missing)
    /// </summary>
    public async Task EnsureBotsExistAsync(int count)
    {
        if (count <= 0 || count > MaxBotCount)
        {
            _logger.LogWarning("Invalid bot count requested: {Count}. Max allowed: {MaxBotCount}", count, MaxBotCount);
            return;
        }

        // Get existing bots - use ToList to detach from tracking
        var existingBots = (await _repository.FindAsync<User>(u => u.IsBot)).ToList();
        var existingBotCount = existingBots.Count;

        if (existingBotCount >= count)
        {
            _logger.LogInformation("{ExistingCount} bots already exist, which is sufficient for {RequestedCount}", 
                existingBotCount, count);
            return;
        }

        // Create missing bots
        var botsToCreate = count - existingBotCount;
        _logger.LogInformation("Creating {BotsToCreate} new bot users", botsToCreate);

        // Bot UserIds start from 1000001 to avoid conflicts with real users
        const long BotUserIdStart = 1000000;

        for (int i = existingBotCount + 1; i <= count; i++)
        {
            var bot = new User
            {
                UserId = BotUserIdStart + i, // Explicit UserId assignment
                Username = $"Bot_{i}",
                PhoneNumber = $"BOT_{i}",
                PasswordHash = "BOT_NO_PASSWORD",
                Balance = 0,
                IsBot = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            await _repository.AddAsync(bot);
            // Save after each bot to avoid EF tracking conflicts
            await _repository.SaveChanges();
        }

        _logger.LogInformation("Successfully created {BotsToCreate} bot users", botsToCreate);
    }

    /// <summary>
    /// Gets a requested number of available bots that are not already in the specified room.
    /// This drastically improves performance by avoiding querying all active players globally.
    /// </summary>
    public async Task<List<User>> GetBotsForRoomAsync(long roomId, int requiredCount)
    {
        var botsInThisRoom = await _repository.FindAsync<RoomPlayer>(rp => rp.RoomId == roomId);
        var excludedBotIds = botsInThisRoom.Select(rp => rp.UserId).ToHashSet();
        
        var allBots = await _repository.FindAsync<User>(u => u.IsBot);
        var availableBots = allBots.Where(b => !excludedBotIds.Contains(b.UserId)).ToList();
        
        if (availableBots.Count == 0)
        {
            _logger.LogWarning("No available bots found for room {RoomId}.", roomId);
            return new List<User>();
        }

        // Shuffle the bots to randomize who joins
        var shuffled = availableBots.OrderBy(x => _random.Next()).ToList();
        return shuffled.Take(requiredCount).ToList();
    }

    /// <summary>
    /// Adds a specific bot to a room and purchases random cards.
    /// Designed to be run concurrently without blocking the main loop.
    /// </summary>
    public async Task<bool> AddSpecificBotToRoomAsync(long roomId, User bot)
    {
        try
        {
            var room = await _repository.FindOneAsync<Room>(r => r.RoomId == roomId);
            
            // STRICT CHECK: Deny join if there is STRICTLY 5 seconds or less left, ignoring ANY previous game waits!
            // This is a hard-enforced database rejection rule.
            bool isTooLate = room?.ScheduledStartTime.HasValue == true && (room.ScheduledStartTime.Value - DateTime.UtcNow).TotalSeconds <= 5;

            if (room == null || room.Status != RoomStatusEnum.Waiting || isTooLate)
            {
                _logger.LogWarning("Blocking bot join: Room {RoomId} is starting/InProgress. State: {State}, TimePassed: {Pass}", 
                                   roomId, room?.Status.ToString(), isTooLate);
                return false;
            }

            // Check if bot is already in this room (just in case)
            var existingPlayer = await _repository.FindOneAsync<RoomPlayer>(rp =>
                rp.RoomId == roomId && rp.UserId == bot.UserId);

            if (existingPlayer != null)
            {
                return false;
            }

            // Add bot as a RoomPlayer
            await _repository.AddAsync(new RoomPlayer
            {
                RoomId = roomId,
                UserId = bot.UserId,
                JoinedAt = DateTime.UtcNow,
                IsReady = true
            });
            await _repository.SaveChanges();

            _logger.LogInformation("Bot {BotUsername} joined room {RoomId}", bot.Username, roomId);

            // Purchase 1-2 random cards for the bot
            int cardsToSelect = _random.Next(1, 3); // 1 or 2 cards
            var takenCardIds = await _repository.GetTakenCards(roomId, CancellationToken.None);
            var availableCardIds = Enumerable.Range(1, 200)
                .Except(takenCardIds.Select(id => (int)id))
                .ToList();

            if (!availableCardIds.Any())
            {
                return true; // Bot joined but couldn't select cards
            }

            for (int i = 0; i < cardsToSelect && availableCardIds.Any(); i++)
            {
                var randomIndex = _random.Next(availableCardIds.Count);
                var selectedCardId = availableCardIds[randomIndex];
                availableCardIds.RemoveAt(randomIndex);

                try
                {
                    bool reserved = await _repository.ReserveCardAsync(bot.UserId, roomId, selectedCardId);
                    
                    if (reserved)
                    {
                         await _repository.PurchaseReservedCardsAsync(bot.UserId, roomId, new List<int> { selectedCardId });

                        // Broadcast SignalR update so lobby shows card as taken
                        await _hubContext.Clients.Group(roomId.ToString())
                            .SendAsync("CardSelectionChanged", selectedCardId, true, bot.UserId);
                    }
                }
                catch (Exception)
                {
                    // Ignore DB constraint collisions for bots and continue
                }
            }

            await _repository.SaveChanges();
            
            // Broadcast room stats update (player count and prize pool)
            if (room != null)
            {
                var playerCount = await _repository.CountAsync<RoomPlayer>(rp => rp.RoomId == roomId);
                var cardCount = await _repository.CountAsync<Card>(c => c.RoomId == roomId);
                var prizePool = cardCount * room.CardPrice * 0.87m; // 87% of total
                
                await _hubContext.Clients.Group(roomId.ToString())
                    .SendAsync("RoomStatsUpdated", roomId, playerCount, prizePool);
            }
            
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error adding specific bot {BotId} to room {RoomId}", bot.UserId, roomId);
            return false;
        }
    }

    /// <summary>
    /// Add bots to a room as RoomPlayers
    /// </summary>
    public async Task AddBotsToRoomAsync(long roomId, int botCount)
    {
        if (botCount <= 0)
        {
            _logger.LogInformation("No bots to add to room {RoomId}", roomId);
            return;
        }

        _logger.LogInformation("Adding {BotCount} bots to room {RoomId}", botCount, roomId);

        // Ensure we have enough bots in the database
        await EnsureBotsExistAsync(botCount);

        // Get bot users
        var bots = (await _repository.FindAsync<User>(u => u.IsBot))
            .OrderBy(b => b.UserId)
            .Take(botCount)
            .ToList();

        if (bots.Count < botCount)
        {
            _logger.LogWarning("Could only find {FoundCount} bots, but {RequestedCount} were requested", 
                bots.Count, botCount);
        }

        // Add each bot as a RoomPlayer
        foreach (var bot in bots)
        {
            // Check if bot is already in this room
            var existingPlayer = await _repository.FindOneAsync<RoomPlayer>(rp =>
                rp.RoomId == roomId && rp.UserId == bot.UserId);

            if (existingPlayer == null)
            {
                await _repository.AddAsync(new RoomPlayer
                {
                    RoomId = roomId,
                    UserId = bot.UserId,
                    JoinedAt = DateTime.UtcNow,
                    IsReady = true // Bots are always ready
                });
            }
        }

        await _repository.SaveChanges();
        _logger.LogInformation("Successfully added {BotCount} bots to room {RoomId}", bots.Count, roomId);
    }

    /// <summary>
    /// Purchase random cards for all bots in a room
    /// </summary>
    public async Task PurchaseCardsForBotsAsync(long roomId)
    {
        _logger.LogInformation("Purchasing cards for bots in room {RoomId}", roomId);

        // Get all bot players in this room
        var botPlayers = await _repository.FindAsync<RoomPlayer>(rp =>
            rp.RoomId == roomId && rp.User.IsBot);

        if (!botPlayers.Any())
        {
            _logger.LogInformation("No bots found in room {RoomId}", roomId);
            return;
        }

        // Get already taken card IDs
        var takenCardIds = await _repository.GetTakenCards(roomId, CancellationToken.None);
        var availableCardIds = Enumerable.Range(1, 200)
            .Except(takenCardIds.Select(id => (int)id))
            .ToList();

        if (!availableCardIds.Any())
        {
            _logger.LogWarning("No available cards for bots in room {RoomId}", roomId);
            return;
        }

        foreach (var botPlayer in botPlayers)
        {
            // Each bot gets 1-3 random cards
            int cardsPerBot = _random.Next(1, 4);

            for (int i = 0; i < cardsPerBot && availableCardIds.Any(); i++)
            {
                // Pick a random card from available cards
                var randomIndex = _random.Next(availableCardIds.Count);
                var selectedCardId = availableCardIds[randomIndex];
                availableCardIds.RemoveAt(randomIndex);

                // Purchase the card for the bot
                try
                {
                    bool reserved = await _repository.ReserveCardAsync(botPlayer.UserId, roomId, selectedCardId);
                    if (reserved)
                    {
                        await _repository.PurchaseReservedCardsAsync(botPlayer.UserId, roomId, new List<int> { selectedCardId });
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to purchase card {CardId} for bot {BotId} in room {RoomId}",
                        selectedCardId, botPlayer.UserId, roomId);
                }
            }
        }

        await _repository.SaveChanges();
        _logger.LogInformation("Finished purchasing cards for bots in room {RoomId}", roomId);
    }

    /// <summary>
    /// Check all bot cards for wins and automatically claim them
    /// </summary>
    public async Task CheckBotWinsAsync(long roomId, List<int> calledNumbers)
    {
        // Get the room to check its pattern
        var room = await _repository.FindOneAsync<Room>(r => r.RoomId == roomId);
        if (room == null || room.Status != RoomStatusEnum.InProgress)
        {
            return;
        }

        // Get all bots in this room
        var botPlayers = await _repository.FindAsync<RoomPlayer>(rp =>
            rp.RoomId == roomId && rp.User.IsBot);

        foreach (var botPlayer in botPlayers)
        {
            // Get bot's cards
            var botCards = await _repository.GetUserCardsInRoomAsync(botPlayer.UserId, roomId);

            if (botCards == null || !botCards.Any())
            {
                continue;
            }

            // Check each card for a win
            foreach (var card in botCards)
            {
                bool hasWin = await _repository.VerifyWinAsync(card.CardId, room.Pattern);

                if (hasWin)
                {
                    _logger.LogInformation("Bot {BotId} has a winning card {CardId} in room {RoomId}",
                        botPlayer.UserId, card.CardId, roomId);

                    // Auto-claim the win for the bot
                    try
                    {
                        await _mediator.Send(new ClaimWinCommand(
                            roomId,
                            botPlayer.UserId,
                            card.CardId,
                            (WinTypeEnum)room.Pattern
                        ));

                        _logger.LogInformation("Successfully claimed win for bot {BotId}", botPlayer.UserId);
                        
                        // One win per bot is enough, stop checking this bot's other cards
                        break;
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to claim win for bot {BotId} in room {RoomId}",
                            botPlayer.UserId, roomId);
                    }
                }
            }
        }
    }
}
