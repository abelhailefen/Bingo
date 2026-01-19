using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Features.Rooms.Contract.Query;
using Bingo.Core.Features.Rooms.DTOs;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.Rooms.Handler;

public class GetRoomDetailsQueryHandler : IRequestHandler<GetRoomDetailsQuery, Response<RoomDto>>
{
    private readonly IBingoRepository _repository;

    public GetRoomDetailsQueryHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<RoomDto>> Handle(GetRoomDetailsQuery request, CancellationToken cancellationToken)
    {
        // 1. Fetch room with CalledNumbers and Cards (including MasterCard templates)
        var room = await _repository.GetActiveRoomWithPlayersAsync(request.RoomId);

        if (room == null) return Response<RoomDto>.NotFound("Room not found");

        // 2. Create a HashSet of the numbers that have been called in this room
        // If room.CalledNumbers is a list of objects, use n.Number. 
        // If the error 'short' persists, it means 'n' is already the number.
        var calledSet = room.CalledNumbers.Select(n => n.Number).ToHashSet();

        // 3. Map Entity to DTO
        var dto = new RoomDto
        {
            RoomId = room.RoomId,
            Name = room.Name,
            RoomCode = room.RoomCode,
            Status = (int)room.Status,
            // Map the list of called numbers to the DTO
            CalledNumbers = calledSet.ToList(),

            Cards = room.Cards.Select(c => new CardDto
            {
                CardId = (int)c.CardId,
                UserId = (int)c.UserId,
                Numbers = c.MasterCard.Numbers.Select(n => new CardNumberDto
                {
                    Number = n.Number,
                    PositionRow = n.PositionRow,
                    PositionCol = n.PositionCol,
                    // LOGIC: Center star (null) is always marked, 
                    // otherwise check if the number is in the calledSet
                    IsMarked = n.Number == null || calledSet.Contains(n.Number.Value)
                }).ToList()
            }).ToList()
        };

        return Response<RoomDto>.Success(dto);
    }
}
