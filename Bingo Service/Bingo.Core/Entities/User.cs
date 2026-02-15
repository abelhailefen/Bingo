using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Entities
{
    public class User
    {
        public long UserId { get; set; }
        public string Username { get; set; } = null!;
        public string PhoneNumber { get; set; } = null!;
        public string PasswordHash { get; set; } = null!;
        public decimal Balance { get; set; }
        public bool IsBot { get; set; } = false;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }

        // Navigation
        public ICollection<RoomPlayer> RoomParticipations { get; set; } = new List<RoomPlayer>();
    }
}
