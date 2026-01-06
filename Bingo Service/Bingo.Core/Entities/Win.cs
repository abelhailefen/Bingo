using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Bingo.Core.Entities.Enums;

namespace Bingo.Core.Entities
{
    public class Win
    {
        public long WinId { get; set; }
        public long RoomId { get; set; }
        public long CardId { get; set; }
        public long UserId { get; set; }
        public DateTime ClaimedAt { get; set; }
        public bool Verified { get; set; }
        public DateTime? VerifiedAt { get; set; }
        public decimal Prize { get; set; }
        public WinTypeEnum WinType { get; set; }
    }
}
