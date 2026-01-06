using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Entities
{
    public class RoomPlayer
    {
        public long RoomPlayerId { get; set; }
        public long RoomId { get; set; }
        public long UserId { get; set; }
        public DateTime JoinedAt { get; set; }
        public bool IsReady { get; set; }

        public Room Room { get; set; } = null!;
        public User User { get; set; } = null!;
    }
}
