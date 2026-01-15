using Bingo.Core.Contract.Repository;
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
            .Include(r => r.Players)
                .ThenInclude(p => p.User)
            .FirstOrDefaultAsync(r => r.RoomId == roomId);
    }

    public async Task<List<Card>> GetUserCardsInRoomAsync(long userId, long roomId)
    {
        return await _context.Cards
            .Include(c => c.Numbers)
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
        
        // Reload card with numbers
        // card.Numbers = cardNumbers; 
        
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
        foreach (var n in numbers) 
        {
            // PositionRow is 1-based or 0-based?
            // CardGenerator used 1-based (row + 1).
            // CardNumber.cs says 1-5.
            // Repositories usually assume DB state. 
            // If DB is 1-based using smallint.
            // Array is 0-based.
            // Let's adjust.
            if(n.PositionRow >= 1 && n.PositionRow <=5 && n.PositionCol >= 1 && n.PositionCol <= 5)
            {
                 grid[n.PositionRow - 1, n.PositionCol - 1] = n.IsMarked;
            }
        }

        return pattern switch
        {
            WinPatternEnum.FullHouse => numbers.All(n => n.IsMarked),
            WinPatternEnum.Line => CheckLines(grid),
            WinPatternEnum.Blackout => numbers.All(n => n.IsMarked), // Same as fullhouse for now
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
        
        // Diagonals?
        bool d1 = true, d2 = true;
        for(int i=0; i<5; i++)
        {
            if(!grid[i,i]) d1 = false;
            if(!grid[i, 4-i]) d2 = false;
        }
        if (d1 || d2) return true;
        
        return false;
    }

    public async Task RecordWinAsync(Win win)
    {
        await _context.Wins.AddAsync(win);
        await _context.SaveChangesAsync();
    }

    public async Task<User?> GetUserWithDetailsAsync(long userId)
    {
        return await _context.Users
            .Include(u => u.HostedRooms)
            .Include(u => u.RoomParticipations)
            .FirstOrDefaultAsync(u => u.UserId == userId);
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
        await Task.CompletedTask; // Remove is not async
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