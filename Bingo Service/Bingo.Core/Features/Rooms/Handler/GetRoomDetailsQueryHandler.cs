using MediatR;
using Bingo.Core.Features.Rooms.Contract.Query;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;

namespace Bingo.Core.Features.Rooms.Handler;

public class GetRoomDetailsQueryHandler : IRequestHandler<GetRoomDetailsQuery, Response<Room>>
{
    private readonly IBingoRepository _repository;

    public GetRoomDetailsQueryHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<Room>> Handle(GetRoomDetailsQuery request, CancellationToken cancellationToken)
    {
        // Use specific method that includes players
        var room = await _repository.GetActiveRoomWithPlayersAsync(request.RoomId);

        if (room == null)
        {
            return Response<Room>.NotFound("Room not found");
        }

        return Response<Room>.Success(room);
    }
}
