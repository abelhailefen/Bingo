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
    Task<Card> CreateCardWithNumbersAsync(long userId, long roomId, List<List<int>> matrix);
    Task<bool> MarkNumberOnCardAsync(long cardId, int number);
    Task<List<short>> GetCalledNumbersAsync(long roomId);
    Task AddCalledNumberAsync(long roomId, short number);
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
}