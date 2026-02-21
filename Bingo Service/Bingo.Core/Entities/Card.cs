using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Entities
{
    using Bingo.Core.Entities.Enums;

    public class Card
    {
        public long CardId { get; set; }
        public long RoomId { get; set; }
        
        // OwnerId might be null if a card is created but not assigned yet, although we currently assign immediately. 
        // We'll keep UserId. A card belongs to a UserId if it's reserved or purchased.
        public long UserId { get; set; }
        public long MasterCardId { get; set; } 

        public Room Room { get; set; } = null!;
        public User User { get; set; } = null!;
        public MasterCard MasterCard { get; set; } = null!;
        public DateTime PurchasedAt { get; set; }

        // --- NEW PROPERTIES FOR LOCKING ---
        public CardLockState State { get; set; } 
        public DateTime? ReservationExpiresAt { get; set; } 
    }
}

