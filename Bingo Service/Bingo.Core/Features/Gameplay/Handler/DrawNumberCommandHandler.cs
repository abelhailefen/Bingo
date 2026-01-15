using MediatR;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;


namespace Bingo.Core.Features.Gameplay.Handler;

public class DrawNumberCommandHandler : IRequestHandler<DrawNumberCommand, Response<short>>
{
    private readonly IBingoRepository _repository;

    public DrawNumberCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<short>> Handle(DrawNumberCommand request, CancellationToken cancellationToken)
    {
        // Check host permission
        var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);

        if (room == null) return Response<short>.NotFound("Room not found");
        if (room.HostUserId != request.UserId) return Response<short>.Error("Only host can draw numbers");
        if (room.Status != RoomStatusEnum.InProgress) return Response<short>.Error("Game is not in progress");

        // Get Called Numbers
        var calledNumbersList = await _repository.GetCalledNumbersAsync(request.RoomId);
        var usedNumbers = calledNumbersList.ToHashSet();
        
        if (usedNumbers.Count >= 75) return Response<short>.Error("All numbers drawn");

        var random = new Random();
        short number;
        do
        {
            number = (short)random.Next(1, 76);
        } while (usedNumbers.Contains(number));

        await _repository.AddCalledNumberAsync(request.RoomId, number);

        // TODO: SignalR broadcast

        return Response<short>.Success(number);
    }
}
