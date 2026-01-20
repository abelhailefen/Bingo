using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using System.Linq.Expressions;

namespace Bingo.Core.Contract.Repository;

public interface IBingoRepository
{
    // Domain Specific
    Task<Room?> GetRoomByCodeAsync(string code);
    Task<Room?> GetActiveRoomWithPlayersAsync(long roomId);
    Task<List<Card>> GetUserCardsInRoomAsync(long userId, long roomId);

    // Updated: Replaced CreateCardWithNumbersAsync with PickMasterCardAsync
    Task<Card> PickMasterCardAsync(long userId, long roomId, int masterCardId);
    Task<MasterCard> GetMasterCard(long masterCardId, CancellationToken ct);
    Task<Room> GetAvailableRoom(CancellationToken ct);
    Task<List<int>> GetTakenCardIdsAsync(long roomId);
    Task<List<long>> GetTakenCards(long roomId, CancellationToken ct);
    // Removed: MarkNumberOnCardAsync (Marking is now calculated on-the-fly)

    // Updated: Types changed to int to match Entity and DTOs
    Task<List<int>> GetCalledNumbersAsync(long roomId);
    Task AddCalledNumberAsync(long roomId, int number);

    Task UpdateRoomStatusAsync(long roomId, RoomStatusEnum status);
    Task<bool> VerifyWinAsync(long cardId, WinPatternEnum pattern);
    Task RecordWinAsync(Win win);
    Task<User?> GetUserWithDetailsAsync(long userId);

    // Generic
    Task SaveChanges();
    Task<IQueryable<TEntity>> GetQueryAsync<TEntity>(Expression<Func<TEntity, bool>> predicate, bool forUpdate = false) where TEntity : class;
    Task<IQueryable<TEntity>> GetQueryAsync<TEntity>(bool forUpdate = false) where TEntity : class;
    Task AddAsync<TEntity>(TEntity entity) where TEntity : class;
    Task<int> CountAsync<TEntity>(Expression<Func<TEntity, bool>> criteria) where TEntity : class;
    Task<int> CountAsync<TEntity>() where TEntity : class;
    Task DeleteAsync<TEntity>(TEntity entity) where TEntity : class;
    Task DeleteAsync<TEntity>(Expression<Func<TEntity, bool>> criteria) where TEntity : class;
    Task AttachAsync<TEntity>(TEntity entity) where TEntity : class;
    Task<IEnumerable<TEntity>> FindAsync<TEntity>(Expression<Func<TEntity, bool>> criteria) where TEntity : class;
    Task<TEntity?> FindOneAsync<TEntity>(Expression<Func<TEntity, bool>> criteria) where TEntity : class;
    Task UpdateAsync<TEntity>(TEntity entity) where TEntity : class;
}