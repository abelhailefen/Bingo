using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Gameplay.Contract.Command;
using Bingo.Core.Models;
using Bingo.Core.Hubs;
using Bingo.Core.Contract.Hub;
using MediatR;
using Microsoft.AspNetCore.SignalR;

namespace Bingo.Core.Features.Gameplay.Handler;

public class LeaveLobbyCommandHandler : IRequestHandler<LeaveLobbyCommand, Response<bool>>
{
    private readonly IBingoRepository _repository;
    private readonly IHubContext<BingoHub, IBingoHubClient> _hubContext;

    public LeaveLobbyCommandHandler(
        IBingoRepository repository,
        IHubContext<BingoHub, IBingoHubClient> hubContext)
    {
        _repository = repository;
        _hubContext = hubContext;
    }

    public async Task<Response<bool>> Handle(LeaveLobbyCommand request, CancellationToken ct)
    {
        try
        {
            var cardsToRelease = await _repository.FindAsync<Card>(c =>
         c.RoomId == request.RoomId && c.UserId == request.UserId);

            var releasedCardIds = cardsToRelease.Select(c => (int)c.MasterCardId).ToList();

            // 2. Delete from DB
            await _repository.DeleteAsync<Card>(c => c.RoomId == request.RoomId && c.UserId == request.UserId);
            await _repository.DeleteAsync<RoomPlayer>(rp => rp.RoomId == request.RoomId && rp.UserId == request.UserId);
            await _repository.SaveChanges();

            // 3. Broadcast to others that these cards are now free
            foreach (var cardId in releasedCardIds)
            {
                await _hubContext.Clients.Group(request.RoomId.ToString())
                    .CardSelectionChanged(cardId, false, request.UserId); // false means unlocked
            }

            return Response<bool>.Success(true);
        }
        catch (Exception ex)
        {
            // In a real app, log the exception here
            return Response<bool>.Error($"Failed to process leave room logic: {ex.Message}");
        }
    }
}