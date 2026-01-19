using MediatR;
using Bingo.Core.Features.Gameplay.Contract.Query;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Features.Rooms.DTOs; // Ensure this is imported

namespace Bingo.Core.Features.Gameplay.Handler;

public class GetPlayerCardsQueryHandler : IRequestHandler<GetPlayerCardsQuery, Response<List<CardDto>>>
{
    private readonly IBingoRepository _repository;

    public GetPlayerCardsQueryHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<List<CardDto>>> Handle(GetPlayerCardsQuery request, CancellationToken cancellationToken)
    {
        var cards = await _repository.GetUserCardsInRoomAsync(request.UserId, request.RoomId);

        // If GetCalledNumbersAsync returns List<short> or List<int>
        var calledNumbers = await _repository.GetCalledNumbersAsync(request.RoomId);

        // Fix: cn IS the number, so we don't need .Number
        // We cast to (int) to ensure it matches the CardNumberDto.Number type
        var calledSet = calledNumbers.Select(n => (int)n).ToHashSet();

        var cardDtos = cards.Select(c => new CardDto
        {
            CardId = (int)c.CardId,
            UserId = (int)c.UserId,
            Numbers = c.MasterCard.Numbers.Select(n => new CardNumberDto
            {
                Number = n.Number,
                PositionRow = n.PositionRow,
                PositionCol = n.PositionCol,
                // Logic: center is null (marked), or value exists in the set
                IsMarked = n.Number == null || (n.Number.HasValue && calledSet.Contains(n.Number.Value))
            }).ToList()
        }).ToList();

        return Response<List<CardDto>>.Success(cardDtos);
    }
}