using MediatR;
using Bingo.Core.Features.Admin.Contract.Query;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;

namespace Bingo.Core.Features.Admin.Handler;

public class GetSystemStatsQueryHandler : IRequestHandler<GetSystemStatsQuery, Response<SystemStatsDto>>
{
    private readonly IBingoRepository _repository;

    public GetSystemStatsQueryHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<SystemStatsDto>> Handle(GetSystemStatsQuery request, CancellationToken cancellationToken)
    {
        var activeRooms = await _repository.CountAsync<Room>(r => r.Status == RoomStatusEnum.Waiting || r.Status == RoomStatusEnum.InProgress);
        var totalPlayers = await _repository.CountAsync<User>(); 
        var completedGames = await _repository.CountAsync<Room>(r => r.Status == RoomStatusEnum.Completed);

        return Response<SystemStatsDto>.Success(new SystemStatsDto
        {
            ActiveRooms = activeRooms,
            TotalPlayers = totalPlayers,
            TotalGamesPlayed = completedGames
        });
    }
}
