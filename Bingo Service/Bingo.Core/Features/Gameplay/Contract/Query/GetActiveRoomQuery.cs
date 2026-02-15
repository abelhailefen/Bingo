using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.Gameplay.Contract.Query
{
    public record GetActiveRoomQuery(long UserId) : IRequest<Response<ActiveRoomResponse>>;
    
    public class ActiveRoomResponse
    {
        public long RoomId { get; set; }
        public decimal CardPrice { get; set; }
    }
}
