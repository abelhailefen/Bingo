using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Entities
{
    public class MasterCardNumber
    {
        public long MasterCardNumberId { get; set; } // Change to long
        public long MasterCardId { get; set; }       // MUST match MasterCardId type (long)
        public int PositionRow { get; set; }
        public int PositionCol { get; set; }
        public int? Number { get; set; }

        public MasterCard MasterCard { get; set; } = null!;
    }
}
