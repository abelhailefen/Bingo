using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Features.Rooms.Contract.Query;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.Rooms.Handler;

public class GetTakenCardsQueryHandler : IRequestHandler<GetTakenCardsQuery, Response<List<int>>>
{
    private readonly IBingoRepository _repository;

    public GetTakenCardsQueryHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<List<int>>> Handle(GetTakenCardsQuery request, CancellationToken ct)
    {
        // Use the generic GetQueryAsync to fetch MasterCardIds from the Cards table
        var takenIds = await _repository.GetTakenCardIdsAsync(request.RoomId);



        return Response<List<int>>.Success(takenIds);
    }
}