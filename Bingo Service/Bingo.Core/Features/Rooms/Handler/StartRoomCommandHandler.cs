using MediatR;
using Bingo.Core.Features.Rooms.Contract.Command;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;

namespace Bingo.Core.Features.Rooms.Handler;

public class StartRoomCommandHandler : IRequestHandler<StartRoomCommand, Response<string>>
{
    private readonly IBingoRepository _repository;

    public StartRoomCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<string>> Handle(StartRoomCommand request, CancellationToken cancellationToken)
    {
//        var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
// Instead of finding and updating manually, invoke UpdateRoomStatusAsync if simplified, 
// BUT we need to check constraints like HostUserId.
        
        var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);

        if (room == null)
        {
            return Response<string>.NotFound("Room not found");
        }

        if (room.HostUserId != request.UserId)
        {
            return Response<string>.Error("Only host can start the room");
        }

        if (room.Status != RoomStatusEnum.Waiting)
        {
            return Response<string>.Error("Room is not in waiting state");
        }
        
        // Use repository method or update entity and save?
        // Repo has UpdateRoomStatusAsync which also sets StartedAt.
        // Let's use that for cleaner code.
        
        await _repository.UpdateRoomStatusAsync(room.RoomId, RoomStatusEnum.InProgress);

        // TODO: Notify players via SignalR

        return Response<string>.Success("Room started");
    }
}
