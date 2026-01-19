using MediatR;
using Bingo.Core.Features.Rooms.Contract.Query;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;

namespace Bingo.Core.Features.Rooms.Handler;

public class GetRoomsQueryHandler : IRequestHandler<GetRoomsQuery, Response<List<RoomSummaryDto>>>
{
    private readonly IBingoRepository _repository;

    public GetRoomsQueryHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<List<RoomSummaryDto>>> Handle(GetRoomsQuery request, CancellationToken cancellationToken)
    {
        
        IEnumerable<Room> rooms;
        if (request.Status.HasValue)
        {
             rooms = await _repository.FindAsync<Room>(r => r.Status == request.Status.Value);
        }
        else
        {
             rooms = await _repository.FindAsync<Room>(r => true);
        }
        
        var dtos = rooms.Select(r => new RoomSummaryDto
        {
                RoomId = r.RoomId,
                RoomCode = r.RoomCode,
                Name = r.Name,
                Status = r.Status,
                MaxPlayers = r.MaxPlayers,
                CardPrice = r.CardPrice,
                PlayerCount = r.Players.Count 
        }).ToList();

        return Response<List<RoomSummaryDto>>.Success(dtos);
    }
}
