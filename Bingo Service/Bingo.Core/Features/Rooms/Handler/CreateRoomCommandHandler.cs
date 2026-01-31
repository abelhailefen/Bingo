using MediatR;
using Bingo.Core.Features.Rooms.Contract.Command;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;

namespace Bingo.Core.Features.Rooms.Handler;

public class CreateRoomCommandHandler : IRequestHandler<CreateRoomCommand, Response<CreateRoomResponse>>
{
    private readonly IBingoRepository _repository;

    public CreateRoomCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<CreateRoomResponse>> Handle(CreateRoomCommand request, CancellationToken cancellationToken)
    {
        // Generate Unique Room Code
        string roomCode;
        bool exists;
        do
        {
            roomCode = GenerateRoomCode();
            exists = (await _repository.GetRoomByCodeAsync(roomCode)) != null;
        } while (exists);

        var room = new Room
        {
            Name = request.Name,
            MaxPlayers = request.MaxPlayers,
            CardPrice = request.CardPrice,
            Pattern = request.Pattern,
            RoomCode = roomCode,
            Status = RoomStatusEnum.Waiting
        };

        await _repository.AddAsync(room);
        await _repository.SaveChanges();

        return Response<CreateRoomResponse>.Success(new CreateRoomResponse(room.RoomId, room.RoomCode));
    }

    private string GenerateRoomCode()
    {
        const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        var random = new Random();
        return new string(Enumerable.Repeat(chars, 6)
            .Select(s => s[random.Next(s.Length)]).ToArray());
    }
}
