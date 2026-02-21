using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Hubs;
using Bingo.Core.Models;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Handler
{
    public class PurchaseCardsCommandHandler : IRequestHandler<PurchaseCardsCommand, Response<bool>>
    {
        private readonly IBingoRepository _repository;
        private readonly IHubContext<BingoHub> _hubContext;

        public PurchaseCardsCommandHandler(IBingoRepository repository, IHubContext<BingoHub> hubContext)
        {
            _repository = repository;
            _hubContext = hubContext;
        }

        public async Task<Response<bool>> Handle(PurchaseCardsCommand request, CancellationToken cancellationToken)
        {
            try
            {
                // 1. Validation: Max 2 Cards
                if (request.MasterCardIds.Count == 0 || request.MasterCardIds.Count > 2)
                {
                    return Response<bool>.Error("You must purchase 1 or 2 cards.");
                }

                // 2. Load Room and Validate Status
                var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
                if (room == null || room.Status != RoomStatusEnum.Waiting)
                {
                    return Response<bool>.Error("Room is not available for joining.");
                }

                // 3. Load User
                var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);
                if (user == null)
                {
                    return Response<bool>.Error("User not found.");
                }

                // 4. Calculate Total Cost & Check Balance
                var totalCost = room.CardPrice * request.MasterCardIds.Count;
                if (user.Balance < totalCost)
                {
                    return Response<bool>.Error($"Insufficient balance. You need {totalCost} Birr but have {user.Balance} Birr.");
                }

                // 5. ATOMIC PURCHASE TRANSACTION: Ensure the user actually holds valid reservations
                bool purchased = await _repository.PurchaseReservedCardsAsync(request.UserId, request.RoomId, request.MasterCardIds);
                if (!purchased)
                {
                    return Response<bool>.Error("Purchase failed. Your reservations may have expired or you did not select these cards.");
                }

                // 6. Deduct Balance ONLY if the purchase succeeded
                user.Balance -= totalCost;
                user.UpdatedAt = DateTime.UtcNow;
                await _repository.UpdateAsync(user);

                // 7. Mark Player as Ready
                var roomPlayer = await _repository.FindOneAsync<RoomPlayer>(rp => rp.RoomId == request.RoomId && rp.UserId == request.UserId);
                if (roomPlayer != null)
                {
                    roomPlayer.IsReady = true;
                    await _repository.UpdateAsync(roomPlayer);
                }

                await _repository.SaveChanges();
                
                // 8. Broadcast room stats & specific card purchases
                var playerCount = await _repository.CountAsync<RoomPlayer>(rp => rp.RoomId == request.RoomId);
                
                // Count active/purchased cards for the prize pool
                var cardCount = await _repository.CountAsync<Card>(c => 
                    c.RoomId == request.RoomId && c.State == CardLockState.Purchased);
                    
                var prizePool = cardCount * room.CardPrice * 0.87m;
                
                await _hubContext.Clients.Group(request.RoomId.ToString())
                    .SendAsync("RoomStatsUpdated", request.RoomId, playerCount, prizePool, cancellationToken: cancellationToken);

                // Tell everyone else the cards are officially bought
                foreach (var masterCardId in request.MasterCardIds)
                {
                    await _hubContext.Clients.Group(request.RoomId.ToString())
                        .SendAsync("CardSelectionChanged", masterCardId, true, request.UserId, cancellationToken: cancellationToken);
                }

                return Response<bool>.Success(true);
            }
            catch (Exception ex)
            {
                // Log exception
                return Response<bool>.Error($"Purchase failed due to an internal error.");
            }
        }
    }
}
