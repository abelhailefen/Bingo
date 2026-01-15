using MediatR;
using Bingo.Core.Features.Rooms.Contract.Command;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;

namespace Bingo.Core.Features.Rooms.Handler;

public class EndRoomCommandHandler : IRequestHandler<EndRoomCommand, Response<string>>
{
    private readonly IBingoRepository _repository;

    public EndRoomCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<string>> Handle(EndRoomCommand request, CancellationToken cancellationToken)
    {
        var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);

        if (room == null)
        {
            return Response<string>.NotFound("Room not found");
        }

        if (room.HostUserId != request.UserId)
        {
            return Response<string>.Error("Only host can end the room");
        }

        await _repository.UpdateRoomStatusAsync(room.RoomId, RoomStatusEnum.Completed);

        return Response<string>.Success("Room ended");
    }
}
