using Bingo.Core.Contract.Hub;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
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
                // 1. Check Limits (Max 2 cards)
                var userCards = await _repository.FindAsync<Card>(c => 
                    c.RoomId == request.RoomId && c.UserId == request.UserId);
                    
                var activeUserCards = userCards.Where(c => 
                    c.State == CardLockState.Purchased || 
                    (c.State == CardLockState.Reserved && c.ReservationExpiresAt > DateTime.UtcNow)).ToList();

                // Idempotency check: if we already reserved/purchased THIS card, we are good
                if (activeUserCards.Any(c => c.MasterCardId == request.MasterCardId))
                {
                    return Response<bool>.Success(true);
                }

                if (activeUserCards.Count >= 2)
                    return Response<bool>.Error("You can only choose a maximum of 2 cards.");

                // STRICT DATE CHECK: If the room is already starting, block new reservations
                var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
                if (room == null || room.Status != RoomStatusEnum.Waiting || (room.ScheduledStartTime.HasValue && room.ScheduledStartTime.Value <= DateTime.UtcNow))
                {
                    return Response<bool>.Error("Game has started! No new cards can be selected.");
                }

                // 2. Atomically attempt to reserve
                bool reserved = await _repository.ReserveCardAsync(request.UserId, request.RoomId, request.MasterCardId);
                
                if (!reserved)
                {
                    return Response<bool>.Error("This card is already taken or actively being previewed by another player.");
                }
            }
            else
            {
                // UNSELECT LOGIC: Release the reservation explicitly
                await _repository.ReleaseCardReservationAsync(request.UserId, request.RoomId, request.MasterCardId);
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