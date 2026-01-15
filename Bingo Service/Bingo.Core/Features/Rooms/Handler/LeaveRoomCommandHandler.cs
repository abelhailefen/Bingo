using MediatR;
using Bingo.Core.Features.Rooms.Contract.Command;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;

namespace Bingo.Core.Features.Rooms.Handler;

public class LeaveRoomCommandHandler : IRequestHandler<LeaveRoomCommand, Response<string>>
{
    private readonly IBingoRepository _repository;

    public LeaveRoomCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<string>> Handle(LeaveRoomCommand request, CancellationToken cancellationToken)
    {
        var player = await _repository.FindOneAsync<RoomPlayer>(rp => rp.RoomId == request.RoomId && rp.UserId == request.UserId);

        if (player == null)
        {
            return Response<string>.NotFound("Player not found in room");
        }

        await _repository.DeleteAsync(player);
        await _repository.SaveChanges();

        return Response<string>.Success("Left room successfully");
    }
}
