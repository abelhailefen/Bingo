using Bingo.Core.Gameplay.Contract.Command;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Gameplay.Handler.Command;

public class BuyCardsCommandHandler : IRequestHandler<BuyCardsCommand, Response<List<Card>>>
{
    private readonly IBingoRepository _repo;

    public BuyCardsCommandHandler(IBingoRepository repo)
    {
        _repo = repo;
    }

    public async Task<Response<List<Card>>> Handle(BuyCardsCommand request, CancellationToken ct)
    {
        // 1. Fetch Room and User
        var room = await _repo.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
        var user = await _repo.FindOneAsync<User>(u => u.UserId == request.UserId);

        if (room == null) return Response<List<Card>>.NotFound("Room not found");
        if (user == null) return Response<List<Card>>.NotFound("User not found");

        // 2. Room Status Check (Can only buy while waiting)
        if (room.Status != RoomStatusEnum.Waiting)
            return Response<List<Card>>.Error("Cannot buy cards. Game has already started or ended.");

        // 3. Max 2 Cards Logic
        var existingCards = await _repo.GetUserCardsInRoomAsync(user.UserId, room.RoomId);
        int totalRequested = request.ChosenMasterCardIds?.Count ?? request.Quantity;

        if (existingCards.Count + totalRequested > 2)
            return Response<List<Card>>.Error("You can only have a maximum of 2 cards per room.");

        // 4. Balance Check
        decimal totalCost = room.CardPrice * totalRequested;
        if (user.Balance < totalCost)
            return Response<List<Card>>.Error("Insufficient balance");

        // 5. Determine which MasterCard IDs to assign
        var idsToAssign = new List<int>();
        if (request.ChosenMasterCardIds != null && request.ChosenMasterCardIds.Any())
        {
            idsToAssign = request.ChosenMasterCardIds;
        }
        else
        {
            // Pick random IDs from 1-200 that the user doesn't already have
            var existingTemplateIds = existingCards.Select(c => (int)c.MasterCardId).ToHashSet();
            var rng = new Random();
            while (idsToAssign.Count < request.Quantity)
            {
                int randomId = rng.Next(1, 201); // 1 to 200
                if (!existingTemplateIds.Contains(randomId) && !idsToAssign.Contains(randomId))
                {
                    idsToAssign.Add(randomId);
                }
            }
        }

        // 6. Process Purchase
        user.Balance -= totalCost;
        var purchasedCards = new List<Card>();

        foreach (var masterId in idsToAssign)
        {
            // PickMasterCardAsync creates the Card record linking User-Room-MasterTemplate
            var newCard = await _repo.PickMasterCardAsync(user.UserId, room.RoomId, masterId);
            purchasedCards.Add(newCard);
        }

        // Save balance update and card creations
        await _repo.SaveChanges();

        return Response<List<Card>>.Success(purchasedCards);
    }
}