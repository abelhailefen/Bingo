using Bingo.Core.Contract.Hub;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Models;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using Bingo.Core.Hubs;

namespace Bingo.Core.Features.Gameplay.Handler
{
    public class SelectCardCommandHandler : IRequestHandler<SelectCardCommand, Response<bool>>
    {
        private readonly IBingoRepository _repository;
        private readonly IHubContext<BingoHub, IBingoHubClient> _hubContext;

        public SelectCardCommandHandler(IBingoRepository repository, IHubContext<BingoHub, IBingoHubClient> hubContext)
        {
            _repository = repository;
            _hubContext = hubContext;
        }

        public async Task<Response<bool>> Handle(SelectCardCommand request, CancellationToken ct)
        {
            if (request.IsSelecting)
            {
                // 1. Check if THIS specific user already has this card (Idempotency)
                var alreadyMine = await _repository.CountAsync<Card>(c =>
                    c.RoomId == request.RoomId &&
                    c.UserId == request.UserId &&
                    c.MasterCardId == request.MasterCardId) > 0;

                // If I already own it, just return success so the UI stays in sync
                if (alreadyMine) return Response<bool>.Success(true);

                // 2. Check if SOMEONE ELSE has this card
                var isTakenByOther = await _repository.CountAsync<Card>(c =>
                    c.RoomId == request.RoomId &&
                    c.MasterCardId == request.MasterCardId) > 0;

                if (isTakenByOther)
                    return Response<bool>.Error("This card has been snatched by another player!");

                // 3. Check Limit (Max 2)
                var userCardCount = await _repository.CountAsync<Card>(c =>
                    c.RoomId == request.RoomId && c.UserId == request.UserId);

                if (userCardCount >= 2)
                    return Response<bool>.Error("You can only choose a maximum of 2 cards.");

                // 4. Save the selection
                // REMOVED: Do not persist card reservation without payment.
                // await _repository.PickMasterCardAsync(request.UserId, request.RoomId, request.MasterCardId);
            }
            else
            {
                // UNSELECT LOGIC: Remove the record from the database
                // REMOVED:
                // await _repository.DeleteAsync<Card>(c =>
                //     c.RoomId == request.RoomId &&
                //     c.UserId == request.UserId &&
                //     c.MasterCardId == request.MasterCardId);
                
                // await _repository.SaveChanges();
            }

            // 5. BROADCAST THE CHANGE
            // This ensures everyone else's grid updates (greying out or enabling the button)
            // and the sender's UI knows the action was confirmed.
            // Use OthersInGroup so the person who clicked doesn't get a redundant (and confusing) websocket message
            // Use .Group instead of .OthersInGroup
            await _hubContext.Clients.Group(request.RoomId.ToString())
                .CardSelectionChanged(request.MasterCardId, request.IsSelecting, request.UserId);
            return Response<bool>.Success(true);
        }
    }
}