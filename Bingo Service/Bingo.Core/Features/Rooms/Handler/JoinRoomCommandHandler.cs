using MediatR;
using Bingo.Core.Features.Rooms.Contract.Command;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Services;

namespace Bingo.Core.Features.Rooms.Handler;

public class JoinRoomCommandHandler : IRequestHandler<JoinRoomCommand, Response<string>>
{
    private readonly IBingoRepository _repository;

    public JoinRoomCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<string>> Handle(JoinRoomCommand request, CancellationToken cancellationToken)
    {
        var room = await _repository.GetActiveRoomWithPlayersAsync(request.RoomId);

        if (room == null)
        {
            return Response<string>.NotFound("Room not found");
        }

        if (room.Players.Count >= room.MaxPlayers)
        {
            return Response<string>.Error("Room is full");
        }
        
        // Check if already joined
        if (room.Players.Any(p => p.UserId == request.UserId))
        {
             return Response<string>.Success("Already joined");
        }

        var player = new RoomPlayer
        {
            RoomId = request.RoomId,
            UserId = request.UserId,
            JoinedAt = DateTime.UtcNow,
            IsReady = false
        };

        await _repository.AddAsync(player);

        // Generate Card if Room is Free
        if (room.CardPrice == 0)
        {
             // Use Custom Service but pass result to repo?
             // Actually repo has CreateCardWithNumbersAsync helper now which takes a matrix.
             // But existing CardGenerator service logic is static and returns a Card object.
             // I'll stick to AddAsync for simplicity as Repository.AddAsync is generic.
             // Wait, I need to ensure CardGenerator uses CardNumber entities.
             // Yes it does.
             
             // BUT, CardGenerator.GenerateCard returns a Card with nested CardNumbers.
             // If I do _repository.AddAsync(card), EF Core usually handles graph.
             // IBingoRepository.AddAsync maps to _context.Set<T>().AddAsync().
             // This is fine.
             
             var card = CardGenerator.GenerateCard(request.RoomId, request.UserId);
             await _repository.AddAsync(card);
        }

        await _repository.SaveChanges();

        return Response<string>.Success("Joined successfully");
    }
}
