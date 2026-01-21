using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Infrastructure.Context;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;
using System.Threading;

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
        return await _context.Rooms
            .Include(r => r.Players)
                .ThenInclude(p => p.User)
            .Include(r => r.CalledNumbers)
            .Include(r => r.Cards)
                .ThenInclude(c => c.MasterCard)
                    .ThenInclude(m => m.Numbers)
            .FirstOrDefaultAsync(r => r.RoomId == roomId);
    }

    public async Task<List<Card>> GetUserCardsInRoomAsync(long userId, long roomId)
    {
        return await _context.Cards
            .Include(c => c.MasterCard)
                .ThenInclude(m => m.Numbers) // <--- THIS MUST BE HERE
            .Where(c => c.UserId == userId && c.RoomId == roomId)
            .ToListAsync();
    }
    public async Task<MasterCard> GetMasterCard(long masterCardId, CancellationToken ct)
    {
        var query = await GetQueryAsync<MasterCard>(m => m.MasterCardId == masterCardId);
        var masterCard = await query.Include(m => m.Numbers).FirstOrDefaultAsync(ct);

        return masterCard;
    }
    public async Task<Card> PickMasterCardAsync(long userId, long roomId, int masterCardId)
    {
        var card = new Card
        {
            UserId = userId,
            RoomId = roomId,
            MasterCardId = masterCardId,
            PurchasedAt = DateTime.UtcNow
        };

        await _context.Cards.AddAsync(card);
        await _context.SaveChangesAsync();

        // Load templates so DTOs can be built immediately
        await _context.Entry(card).Reference(c => c.MasterCard).LoadAsync();
        await _context.Entry(card.MasterCard).Collection(m => m.Numbers).LoadAsync();

        return card;
    }

    public async Task<List<int>> GetCalledNumbersAsync(long roomId)
    {
        return await _context.CalledNumbers
            .Where(cn => cn.RoomId == roomId)
            .OrderBy(cn => cn.CalledAt)
            .Select(cn => (int)cn.Number)
            .ToListAsync();
    }

    public async Task AddCalledNumberAsync(long roomId, int number)
    {
        await _context.CalledNumbers.AddAsync(new CalledNumber
        {
            RoomId = roomId,
            Number = number,
            CalledAt = DateTime.UtcNow
        });
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
        var card = await _context.Cards
            .Include(c => c.MasterCard)
                .ThenInclude(m => m.Numbers)
            .FirstOrDefaultAsync(c => c.CardId == cardId);

        if (card == null) return false;

        var calledList = await GetCalledNumbersAsync(card.RoomId);
        var calledSet = calledList.ToHashSet();

        var grid = new bool[5, 5];
        foreach (var n in card.MasterCard.Numbers)
        {
            // Center cell (Number is null) is always true, others check calledSet
            bool isMarked = n.Number == null || calledSet.Contains(n.Number.Value);
            grid[n.PositionRow - 1, n.PositionCol - 1] = isMarked;
        }

        return pattern switch
        {
            WinPatternEnum.FullHouse => CheckFullHouse(grid),
            WinPatternEnum.Line => CheckLines(grid),
            WinPatternEnum.Blackout => CheckFullHouse(grid),
            _ => false
        };
    }

    private bool CheckFullHouse(bool[,] grid)
    {
        for (int r = 0; r < 5; r++)
            for (int c = 0; c < 5; c++)
                if (!grid[r, c]) return false;
        return true;
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

        bool d1 = true, d2 = true;
        for (int i = 0; i < 5; i++)
        {
            if (!grid[i, i]) d1 = false;
            if (!grid[i, 4 - i]) d2 = false;
        }
        return d1 || d2;
    }

    public async Task RecordWinAsync(Win win)
    {
        await _context.Wins.AddAsync(win);
        await _context.SaveChangesAsync();
    }

    public async Task<User?> GetUserWithDetailsAsync(long userId)
    {
        return await _context.Users
            .Include(u => u.RoomParticipations)
            .FirstOrDefaultAsync(u => u.UserId == userId);
    }
    public async Task<Room> GetAvailableRoom(CancellationToken ct)
    {
        var roomQuery = await GetQueryAsync<Room>(r => r.Status == RoomStatusEnum.Waiting);
        var room = await roomQuery.OrderBy(r => r.CreatedAt).FirstOrDefaultAsync(ct);
        return room;

    }
    public async Task<List<long>> GetTakenCards(long roomId, CancellationToken ct)
    {
        var cardQuery = await GetQueryAsync<Card>(c => c.RoomId == roomId);
        var takenCardIds = await cardQuery.Select(c => c.MasterCardId).ToListAsync(ct);
        return takenCardIds;


    }
    public async Task<List<int>> GetTakenCardIdsAsync(long roomId)
    {
        return await _context.Cards
            .Where(c => c.RoomId == roomId)
            .Select(c => (int)c.MasterCardId)
            .ToListAsync();
    }
  
    /* ============================================================
     * Generic DB Operations
     * ============================================================ */

    public async Task SaveChanges() => await _context.SaveChangesAsync();

    public async Task<IQueryable<TEntity>> GetQueryAsync<TEntity>(Expression<Func<TEntity, bool>> predicate, bool forUpdate = false) where TEntity : class
    {
        var query = forUpdate ? _context.Set<TEntity>() : _context.Set<TEntity>().AsNoTracking();
        return query.Where(predicate);
    }

    public async Task<IQueryable<TEntity>> GetQueryAsync<TEntity>(bool forUpdate = false) where TEntity : class
    {
        return forUpdate ? _context.Set<TEntity>() : _context.Set<TEntity>().AsNoTracking();
    }

    public async Task AddAsync<TEntity>(TEntity entity) where TEntity : class => await _context.Set<TEntity>().AddAsync(entity);

    public async Task<int> CountAsync<TEntity>(Expression<Func<TEntity, bool>> criteria) where TEntity : class => await _context.Set<TEntity>().CountAsync(criteria);

    public async Task<int> CountAsync<TEntity>() where TEntity : class => await _context.Set<TEntity>().CountAsync();

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
    public async Task UpdateAsync<TEntity>(TEntity entity) where TEntity : class
    {

        var keyName = _context.Model.FindEntityType(typeof(TEntity)).FindPrimaryKey().Properties
            .Select(x => x.Name).Single();
        var keyValue = entity.GetType().GetProperty(keyName).GetValue(entity, null);

        var attachedObject = _context.ChangeTracker
            .Entries<TEntity>().FirstOrDefault(x => x.Metadata.FindPrimaryKey().Properties.First(y => y.Name == keyName) == keyValue);
        if (attachedObject != null)
        {
            attachedObject.State = EntityState.Detached;
        }

        //DbContext.Entry(entity).Property("UpdatedOn").OriginalValue = DbContext.Entry(entity).Property("UpdatedOn").CurrentValue;
        //DbContext.Entry(entity).Property("UpdatedOn").CurrentValue = DateTime.Now;
        _context.Entry(entity).State = EntityState.Modified;
        _context.Set<TEntity>().Update(entity);
    }
}