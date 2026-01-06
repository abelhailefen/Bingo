using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Entities
{
    public class CalledNumber
    {
        public long CalledId { get; set; }
        public long RoomId { get; set; }
        public short Number { get; set; }
        public DateTime CalledAt { get; set; }

        public Room Room { get; set; } = null!;
    }
}
