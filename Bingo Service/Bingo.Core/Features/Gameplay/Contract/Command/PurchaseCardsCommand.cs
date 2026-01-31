using Bingo.Core.Models;
using MediatR;
using System.Collections.Generic;

namespace Bingo.Core.Features.Gameplay.Contract.Command
{
    public class PurchaseCardsCommand : IRequest<Response<bool>>
    {
        public long UserId { get; }
        public long RoomId { get; }
        public List<int> MasterCardIds { get; }

        public PurchaseCardsCommand(long userId, long roomId, List<int> masterCardIds)
        {
            UserId = userId;
            RoomId = roomId;
            MasterCardIds = masterCardIds ?? new List<int>();
        }
    }
}
