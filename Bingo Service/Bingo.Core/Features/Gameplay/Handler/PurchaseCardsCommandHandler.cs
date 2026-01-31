using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Models;
using MediatR;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Handler
{
    public class PurchaseCardsCommandHandler : IRequestHandler<PurchaseCardsCommand, Response<bool>>
    {
        private readonly IBingoRepository _repository;
        private static readonly SemaphoreSlim _semaphore = new SemaphoreSlim(1, 1);

        public PurchaseCardsCommandHandler(IBingoRepository repository)
        {
            _repository = repository;
        }

        public async Task<Response<bool>> Handle(PurchaseCardsCommand request, CancellationToken cancellationToken)
        {
            // Lock to ensure atomicity for user balance and card availability
            await _semaphore.WaitAsync(cancellationToken);
            try
            {
                // 1. Validation: Max 2 Cards
                if (request.MasterCardIds.Count == 0 || request.MasterCardIds.Count > 2)
                {
                    return Response<bool>.Error("You must purchase 1 or 2 cards.");
                }

                // 2. Load Room and Validate Status
                var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
                if (room == null)
                {
                    return Response<bool>.Error("Room not found.");
                }

                if (room.Status != RoomStatusEnum.Waiting)
                {
                    return Response<bool>.Error("Game has already started or finished.");
                }

                // 3. Load User
                var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);
                if (user == null)
                {
                    return Response<bool>.Error("User not found.");
                }

                // 4. Calculate Total Cost
                var totalCost = room.CardPrice * request.MasterCardIds.Count;

                // 5. Balance Check
                if (user.Balance < totalCost)
                {
                    return Response<bool>.Error($"Insufficient balance. You need {totalCost} Birr but have {user.Balance} Birr.");
                }

                // 6. Validate Cards Availability
                var alreadyTakenCards = await _repository.GetTakenCards(request.RoomId, cancellationToken);
                foreach (var cardId in request.MasterCardIds)
                {
                    if (alreadyTakenCards.Contains(cardId))
                    {
                        // Double check if *this* user already owns them (idempotency/retry)
                        // But for simplicity, we assume if it's taken, you can't buy it unless we handle re-purchase logic.
                        // We'll trust GetTakenCards returns all active cards in the room.
                        return Response<bool>.Error($"Card {cardId} is already taken by another player.");
                    }
                }
                // Check if user already has cards in this room? Max 2 total?
                var myCards = await _repository.FindAsync<Card>(c => c.RoomId == request.RoomId && c.UserId == request.UserId);
                var cardList = myCards.ToList();
                if (cardList.Count + request.MasterCardIds.Count > 2)
                {
                    return Response<bool>.Error($"You can only hold a maximum of 2 cards. You already have {cardList.Count}.");
                }


                // 7. Deduct Balance
                user.Balance -= totalCost;
                user.UpdatedAt = DateTime.UtcNow;
                await _repository.UpdateAsync(user); 
                // Note: Assuming generic repository Update marks state as Modified. 
                // Actual save happens at savechanges, but good to be explicit if needed.

                // 8. Create Cards
                foreach (var masterCardId in request.MasterCardIds)
                {
                    var newCard = new Card
                    {
                        UserId = request.UserId,
                        RoomId = request.RoomId,
                        MasterCardId = masterCardId,
                        PurchasedAt = DateTime.UtcNow
                    };
                    await _repository.AddAsync(newCard);
                }

                // 9. Mark Player as Ready?
                // Depending on game flow, buying cards might mean you are ready.
                var roomPlayer = await _repository.FindOneAsync<RoomPlayer>(rp => rp.RoomId == request.RoomId && rp.UserId == request.UserId);
                if (roomPlayer != null)
                {
                    roomPlayer.IsReady = true;
                    // roomPlayer.CardCount += ... if we tracked that on RoomPlayer, but we use Cards table
                     await _repository.UpdateAsync(roomPlayer);
                }

                await _repository.SaveChanges();

                return Response<bool>.Success(true);
            }
            catch (Exception ex)
            {
                // Log exception
                return Response<bool>.Error($"Purchase failed: {ex.Message}");
            }
            finally
            {
                _semaphore.Release();
            }
        }
    }
}
