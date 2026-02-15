using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Query;
using Bingo.Core.Models;
using MediatR;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Handler
{
    public class GetActiveRoomQueryHandler : IRequestHandler<GetActiveRoomQuery, Response<ActiveRoomResponse>>
    {
        private readonly IBingoRepository _repository;

        public GetActiveRoomQueryHandler(IBingoRepository repository)
        {
            _repository = repository;
        }

        public async Task<Response<ActiveRoomResponse>> Handle(GetActiveRoomQuery request, CancellationToken cancellationToken)
        {
            // Find any cards the user has purchased in non-completed rooms
            var userCards = await _repository.FindAsync<Card>(c => c.UserId == request.UserId);
            
            foreach (var card in userCards)
            {
                var room = await _repository.FindOneAsync<Room>(r => 
                    r.RoomId == card.RoomId && 
                    (r.Status == RoomStatusEnum.Waiting || r.Status == RoomStatusEnum.InProgress));
                    
                if (room != null)
                {
                    // User has cards in an active room
                    return Response<ActiveRoomResponse>.Success(new ActiveRoomResponse
                    {
                        RoomId = room.RoomId,
                        CardPrice = room.CardPrice
                    });
                }
            }
            
            // No active room found
            return Response<ActiveRoomResponse>.Error("No active room");
        }
    }
}
