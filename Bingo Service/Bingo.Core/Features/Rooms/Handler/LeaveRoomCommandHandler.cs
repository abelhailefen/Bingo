using MediatR;
using Bingo.Core.Features.Rooms.Contract.Command;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Microsoft.AspNetCore.SignalR;
using Bingo.Core.Hubs;
using Bingo.Core.Contract.Hub;
using System.Linq;

namespace Bingo.Core.Features.Rooms.Handler;

public class LeaveRoomCommandHandler : IRequestHandler<LeaveRoomCommand, Response<string>>
{
    private readonly IBingoRepository _repository;
    private readonly IHubContext<BingoHub, IBingoHubClient> _hubContext;

    public LeaveRoomCommandHandler(IBingoRepository repository, IHubContext<BingoHub, IBingoHubClient> hubContext)
    {
        _repository = repository;
        _hubContext = hubContext;
    }

    public async Task<Response<string>> Handle(LeaveRoomCommand request, CancellationToken cancellationToken)
    {
        var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
        if (room == null) return Response<string>.NotFound("Room not found.");

        var player = await _repository.FindOneAsync<RoomPlayer>(rp => rp.RoomId == request.RoomId && rp.UserId == request.UserId);
        
        if (player == null)
        {
            return Response<string>.NotFound("Player not found in room");
        }

        // If the game is still waiting, we can gracefully process refunds and free up cards
        if (room.Status == RoomStatusEnum.Waiting)
        {
            var userCards = await _repository.FindAsync<Card>(c => c.RoomId == request.RoomId && c.UserId == request.UserId);
            var purchasedCards = userCards.Where(c => c.State == CardLockState.Purchased).ToList();

            if (purchasedCards.Count > 0)
            {
                var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);
                if (user != null)
                {
                    decimal refundAmount = purchasedCards.Count * room.CardPrice;
                    user.Balance += refundAmount;
                    user.UpdatedAt = DateTime.UtcNow;
                    await _repository.UpdateAsync(user);
                }
            }

            // Unilaterally delete all cards (reservations and purchases) so they are freed up
            foreach (var c in userCards)
            {
                await _repository.DeleteAsync(c);
                // Also broadcast they are free for other players to click!
                await _hubContext.Clients.Group(request.RoomId.ToString()).CardSelectionChanged((int)c.MasterCardId, false, request.UserId);
            }
            
            // Delete player
            await _repository.DeleteAsync(player);
            await _repository.SaveChanges();

            // Broadcast stats after saving changes
            var playerCount = await _repository.CountAsync<RoomPlayer>(rp => rp.RoomId == request.RoomId);
            var cardCount = await _repository.CountAsync<Card>(c => c.RoomId == request.RoomId && c.State == CardLockState.Purchased);
            var prizePool = cardCount * room.CardPrice * 0.87m;
            await _hubContext.Clients.Group(request.RoomId.ToString()).RoomStatsUpdated(request.RoomId, playerCount, prizePool);
        }
        else 
        {
            // If the game is InProgress, we just quietly delete the player so they stop seeing the generic UI
            // Their cards are still active on the DB and can naturally win.
            await _repository.DeleteAsync(player);
            await _repository.SaveChanges();
        }

        return Response<string>.Success("Left room successfully");
    }
}
