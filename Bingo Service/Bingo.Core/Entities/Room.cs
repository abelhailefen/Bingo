using Bingo.Core.Entities.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Entities
{
    public class Room
    {
        public long RoomId { get; set; }
        public string RoomCode { get; set; } = null!;
        public string Name { get; set; } = null!;
        public long HostUserId { get; set; }
        public RoomStatusEnum Status { get; set; }
        public int MaxPlayers { get; set; }
        public decimal CardPrice { get; set; }
        public WinPatternEnum Pattern { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? StartedAt { get; set; }
        public DateTime? EndedAt { get; set; }

        // Navigation
        public User Host { get; set; } = null!;
        public ICollection<RoomPlayer> Players { get; set; } = new List<RoomPlayer>();
        public ICollection<Card> Cards { get; set; } = new List<Card>();
        public ICollection<CalledNumber> CalledNumbers { get; set; } = new List<CalledNumber>();
    }
}
