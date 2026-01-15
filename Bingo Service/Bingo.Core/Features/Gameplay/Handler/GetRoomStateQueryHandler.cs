using MediatR;
using Bingo.Core.Features.Gameplay.Contract.Query;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Entities;


namespace Bingo.Core.Features.Gameplay.Handler;

public class GetRoomStateQueryHandler : IRequestHandler<GetRoomStateQuery, Response<RoomStateDto>>
{
    private readonly IBingoRepository _repository;

    public GetRoomStateQueryHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<RoomStateDto>> Handle(GetRoomStateQuery request, CancellationToken cancellationToken)
    {
        var room = await _repository.GetActiveRoomWithPlayersAsync(request.RoomId);

        if (room == null) return Response<RoomStateDto>.NotFound("Room not found");
        
        // Need called numbers and wins
        var calledNumbers = await _repository.GetCalledNumbersAsync(request.RoomId);
        
        var winsQuery = await _repository.FindAsync<Win>(w => w.RoomId == request.RoomId);
        // FindAsync does NOT include User. 
        // We need Username.
        // Limitation of generic repo without specific Includes helper.
        // We can fetch user for each win (N+1) or ignore username for state for now.
        // Or fetch users involved.
        
        // Hack for MVP Clean Arch limits: Fetch users for these wins.
        var userIds = winsQuery.Select(w => w.UserId).Distinct().ToList();
        var users = (await _repository.FindAsync<User>(u => userIds.Contains(u.UserId))).ToDictionary(u => u.UserId);
        
        var wins = winsQuery.Select(w => new WinSummaryDto
            {
                WinId = w.WinId,
                Username = users.ContainsKey(w.UserId) ? users[w.UserId].Username : "Unknown",
                Prize = w.Prize,
                WinType = w.WinType.ToString()
            })
            .ToList();

        var dto = new RoomStateDto
        {
            RoomId = room.RoomId,
            Status = room.Status,
            CalledNumbers = calledNumbers,
            PlayerCount = room.Players.Count,
            Players = room.Players.Select(p => p.User != null ? p.User.Username : "Player").ToList(), // Player User might be null if not included in GetActiveRoomWithPlayersAsync... 
                                                                                                  // Repo method: .Include(r => r.Players). No ThenInclude(User). 
                                                                                                  // Repo: return await _context.Rooms.Include(r => r.Players).FirstOrDefaultAsync...
                                                                                                  // So User is NULL.
                                                                                                  // We need to fix Repo to ThenInclude User.
            Wins = wins
        };

        return Response<RoomStateDto>.Success(dto);
    }
}
