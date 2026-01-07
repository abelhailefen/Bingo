using Bingo.Core.BingoGame.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Infrastructure.Context;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;

namespace Bingo.Infrastructure.Repository;

public class BingoRepository : IBingoRepository
{
    private readonly BingoDbContext _context;

    public BingoRepository(BingoDbContext context)
    {
        _context = context;
    }

    /* ============================================================
     * Specific Bingo Domain Logic
     * ============================================================ */

    public async Task<Room?> GetRoomByCodeAsync(string code)
    {
        return await _context.Rooms
            .FirstOrDefaultAsync(r => r.RoomCode == code);
    }

    public async Task<Room?> GetActiveRoomWithPlayersAsync(long roomId)
    {
        // Example of specific include logic handled in repo
        return await _context.Rooms
            .FirstOrDefaultAsync(r => r.RoomId == roomId);
    }

    public async Task<List<Card>> GetUserCardsInRoomAsync(long userId, long roomId)
    {
        return await _context.Cards
            .Where(c => c.UserId == userId && c.RoomId == roomId)
            .ToListAsync();
    }

    public async Task<Card> CreateCardWithNumbersAsync(long userId, long roomId, List<List<int>> matrix)
    {
        var card = new Card
        {
            UserId = userId,
            RoomId = roomId,
            PurchasedAt = DateTime.UtcNow
        };

        // 1. Add and Save Card first to generate the CardId (long)
        await _context.Cards.AddAsync(card);
        await _context.SaveChangesAsync();

        var cardNumbers = new List<CardNumber>();

        // 2. Iterate using shorts for rows and columns
        for (short row = 0; row < 5; row++)
        {
            for (short col = 0; col < 5; col++)
            {
                cardNumbers.Add(new CardNumber
                {
                    CardId = card.CardId,
                    PositionRow = row,
                    PositionCol = col,
                    Number = (short)matrix[row][col],
                    IsMarked = (row == 2 && col == 2)
                });
            }
        }

        // 3. Bulk insert all card numbers
        await _context.CardNumbers.AddRangeAsync(cardNumbers);
        await _context.SaveChangesAsync();

        return card;
    }

    public async Task<bool> MarkNumberOnCardAsync(long cardId, int number)
    {
        var cardNumber = await _context.CardNumbers
            .FirstOrDefaultAsync(cn => cn.CardId == cardId && cn.Number == number);

        if (cardNumber == null) return false;

        cardNumber.IsMarked = true;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<List<short>> GetCalledNumbersAsync(long roomId)
    {
        return await _context.CalledNumbers
            .Where(cn => cn.RoomId == roomId)
            .OrderBy(cn => cn.CalledAt)
            .Select(cn => cn.Number)
            .ToListAsync();
    }

    public async Task AddCalledNumberAsync(long roomId, short number)
    {
        await _context.CalledNumbers.AddAsync(new CalledNumber
        {
            RoomId = roomId,
            Number = number,
            CalledAt = DateTime.UtcNow
        });

        // HIGH PERFORMANCE UPDATE: 
        // Automatically marks this number for ALL cards in this room 
        // This prevents needing to iterate through 50+ players/cards in code.
        await _context.Database.ExecuteSqlRawAsync(
            "UPDATE card_numbers SET is_marked = true WHERE number = {0} AND card_id IN (SELECT card_id FROM cards WHERE room_id = {1})",
            number, roomId);

        await _context.SaveChangesAsync();
    }

    public async Task UpdateRoomStatusAsync(long roomId, RoomStatusEnum status)
    {
        var room = await _context.Rooms.FindAsync(roomId);
        if (room != null)
        {
            room.Status = status;
            if (status == RoomStatusEnum.InProgress) room.StartedAt = DateTime.UtcNow;
            if (status == RoomStatusEnum.Completed) room.EndedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }
    }

    public async Task<bool> VerifyWinAsync(long cardId, WinPatternEnum pattern)
    {
        var numbers = await _context.CardNumbers
            .Where(cn => cn.CardId == cardId)
            .ToListAsync();

        var grid = new bool[5, 5];
        foreach (var n in numbers) grid[n.PositionRow, n.PositionCol] = n.IsMarked;

        return pattern switch
        {
            WinPatternEnum.FullHouse => numbers.All(n => n.IsMarked),
            WinPatternEnum.Line => CheckLines(grid),
            _ => false
        };
    }

    private bool CheckLines(bool[,] grid)
    {
        for (int i = 0; i < 5; i++)
        {
            bool rowWin = true, colWin = true;
            for (int j = 0; j < 5; j++)
            {
                if (!grid[i, j]) rowWin = false;
                if (!grid[j, i]) colWin = false;
            }
            if (rowWin || colWin) return true;
        }
        return false;
    }

    public async Task RecordWinAsync(Win win)
    {
        await _context.Wins.AddAsync(win);
        await _context.SaveChangesAsync();
    }

    /* ============================================================
     * Generic DB Operations
     * ============================================================ */

    public async Task SaveChanges() => await _context.SaveChangesAsync();

    public async Task<IQueryable<TEntity>> GetQueryAsync<TEntity>(Expression<Func<TEntity, bool>> predicate, bool forUpdate = false) where TEntity : class
    {
        var query = await GetQueryAsync<TEntity>(forUpdate);
        return query.Where(predicate);
    }

    public async Task<IQueryable<TEntity>> GetQueryAsync<TEntity>(bool forUpdate = false) where TEntity : class
    {
        return forUpdate
            ? _context.Set<TEntity>()
            : _context.Set<TEntity>().AsNoTracking();
    }

    public async Task AddAsync<TEntity>(TEntity entity) where TEntity : class
    {
        await _context.Set<TEntity>().AddAsync(entity);
    }

    public async Task<int> CountAsync<TEntity>(Expression<Func<TEntity, bool>> criteria) where TEntity : class
    {
        return await _context.Set<TEntity>().CountAsync(criteria);
    }

    public async Task<int> CountAsync<TEntity>() where TEntity : class
    {
        return await _context.Set<TEntity>().CountAsync();
    }

    public async Task DeleteAsync<TEntity>(TEntity entity) where TEntity : class
    {
        _context.Set<TEntity>().Remove(entity);
        await Task.CompletedTask;
    }

    public async Task DeleteAsync<TEntity>(Expression<Func<TEntity, bool>> criteria) where TEntity : class
    {
        var entities = _context.Set<TEntity>().Where(criteria);
        _context.Set<TEntity>().RemoveRange(entities);
        await Task.CompletedTask;
    }

    public async Task AttachAsync<TEntity>(TEntity entity) where TEntity : class
    {
        _context.Set<TEntity>().Attach(entity);
        await Task.CompletedTask;
    }

    public async Task<IEnumerable<TEntity>> FindAsync<TEntity>(Expression<Func<TEntity, bool>> criteria) where TEntity : class
    {
        return await _context.Set<TEntity>().Where(criteria).ToListAsync();
    }

    public async Task<TEntity?> FindOneAsync<TEntity>(Expression<Func<TEntity, bool>> criteria) where TEntity : class
    {
        return await _context.Set<TEntity>().FirstOrDefaultAsync(criteria);
    }
}