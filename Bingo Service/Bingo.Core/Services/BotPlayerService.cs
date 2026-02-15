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
    /// Calculate how many bots are needed based on real player count
    /// </summary>
    public int GetRequiredBotCount(int realPlayerCount)
    {
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
    /// Get an available bot that is not currently in any active room
    /// </summary>
    public async Task<User?> GetAvailableBotForRoomAsync(long roomId)
    {
        // Get all bots
        var allBots = await _repository.FindAsync<User>(u => u.IsBot);

        // Get bots that are in active rooms (Waiting or InProgress)
        var activePlayers = await _repository.FindAsync<RoomPlayer>(rp =>
            rp.Room.Status == RoomStatusEnum.Waiting || rp.Room.Status == RoomStatusEnum.InProgress);
        
        var busyBotIds = activePlayers.Select(rp => rp.UserId).ToHashSet();

        // Find a bot that's not busy
        var availableBot = allBots.FirstOrDefault(bot => !busyBotIds.Contains(bot.UserId));

        if (availableBot == null)
        {
            _logger.LogWarning("No available bots found for room {RoomId}. All bots are in active rooms.", roomId);
        }

        return availableBot;
    }

    /// <summary>
    /// Add a single bot to a room and have it select 1-2 random cards
    /// This is used for gradual bot joining during countdown
    /// </summary>
    public async Task<bool> AddSingleBotToRoomAsync(long roomId)
    {
        try
        {
            // Get an available bot
            var bot = await GetAvailableBotForRoomAsync(roomId);
            if (bot == null)
            {
                _logger.LogWarning("Cannot add bot to room {RoomId} - no available bots", roomId);
                return false;
            }

            // Check if bot is already in this room
            var existingPlayer = await _repository.FindOneAsync<RoomPlayer>(rp =>
                rp.RoomId == roomId && rp.UserId == bot.UserId);

            if (existingPlayer != null)
            {
                _logger.LogInformation("Bot {BotId} is already in room {RoomId}", bot.UserId, roomId);
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
            var availableCardIds = Enumerable.Range(1, 100)
                .Except(takenCardIds.Select(id => (int)id))
                .ToList();

            if (!availableCardIds.Any())
            {
                _logger.LogWarning("No available cards for bot {BotId} in room {RoomId}", bot.UserId, roomId);
                return true; // Bot joined but couldn't select cards
            }

            for (int i = 0; i < cardsToSelect && availableCardIds.Any(); i++)
            {
                var randomIndex = _random.Next(availableCardIds.Count);
                var selectedCardId = availableCardIds[randomIndex];
                availableCardIds.RemoveAt(randomIndex);

                try
                {
                    await _repository.PickMasterCardAsync(bot.UserId, roomId, selectedCardId);
                    
                    // Broadcast SignalR update so lobby shows card as taken
                    await _hubContext.Clients.Group(roomId.ToString())
                        .SendAsync("CardSelectionChanged", selectedCardId, true, bot.UserId);
                    
                    _logger.LogInformation("Bot {BotUsername} selected card {CardId} in room {RoomId}", 
                        bot.Username, selectedCardId, roomId);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to select card {CardId} for bot {BotId} in room {RoomId}",
                        selectedCardId, bot.UserId, roomId);
                }
            }

            await _repository.SaveChanges();
            
            // Broadcast room stats update (player count and prize pool)
            var room = await _repository.FindOneAsync<Room>(r => r.RoomId == roomId);
            if (room != null)
            {
                var playerCount = await _repository.CountAsync<RoomPlayer>(rp => rp.RoomId == roomId);
                var cardCount = await _repository.CountAsync<Card>(c => c.RoomId == roomId);
                var prizePool = cardCount * room.CardPrice * 0.87m; // 87% of total
                
                await _hubContext.Clients.Group(roomId.ToString())
                    .SendAsync("RoomStatsUpdated", roomId, playerCount, prizePool);
                    
                _logger.LogInformation("Room {RoomId} stats updated: {PlayerCount} players, {PrizePool} prize pool", 
                    roomId, playerCount, prizePool);
            }
            
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error adding single bot to room {RoomId}", roomId);
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
        var availableCardIds = Enumerable.Range(1, 100)
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
                    await _repository.PickMasterCardAsync(botPlayer.UserId, roomId, selectedCardId);
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
