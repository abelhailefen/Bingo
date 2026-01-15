using MediatR;
using Bingo.Core.Features.Gameplay.Contract.Query;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;

namespace Bingo.Core.Features.Gameplay.Handler;

public class GetPlayerCardsQueryHandler : IRequestHandler<GetPlayerCardsQuery, Response<List<Card>>>
{
    private readonly IBingoRepository _repository;

    public GetPlayerCardsQueryHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<List<Card>>> Handle(GetPlayerCardsQuery request, CancellationToken cancellationToken)
    {
        var cards = await _repository.GetUserCardsInRoomAsync(request.UserId, request.RoomId);
        return Response<List<Card>>.Success(cards);
    }
}
