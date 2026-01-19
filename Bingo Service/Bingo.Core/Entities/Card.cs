using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Entities
{
    public class Card
    {
        public long CardId { get; set; }
        public long RoomId { get; set; }
        public long UserId { get; set; }
        public long MasterCardId { get; set; } 

        public Room Room { get; set; } = null!;
        public User User { get; set; } = null!;
        public MasterCard MasterCard { get; set; } = null!;
        public DateTime PurchasedAt { get; set; }
    }
}

