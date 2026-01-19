using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.DTOs
{
    public record JoinLobbyResponse(long RoomId, List<long> LockedCardIds);

}
