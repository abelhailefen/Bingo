using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Entities
{
    public class CardNumber
    {
        public long CardNumberId { get; set; }
        public long CardId { get; set; }
        public short PositionRow { get; set; }
        public short PositionCol { get; set; }
        public short Number { get; set; }
        public bool IsMarked { get; set; }

        public Card Card { get; set; } = null!;
    }
}
