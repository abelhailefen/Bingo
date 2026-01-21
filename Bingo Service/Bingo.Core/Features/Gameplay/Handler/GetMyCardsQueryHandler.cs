using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Features.Gameplay.Contract.Query;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.Gameplay.Handler;

public class GetMyCardsQueryHandler : IRequestHandler<GetMyCardsQuery, Response<List<Card>>>
{
    private readonly IBingoRepository _repository;

    public GetMyCardsQueryHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<List<Card>>> Handle(GetMyCardsQuery request, CancellationToken ct)
    {
        // Use the repository method we verified earlier
        var cards = await _repository.GetUserCardsInRoomAsync(request.UserId, request.RoomId);
        return Response<List<Card>>.Success(cards);
    }
}