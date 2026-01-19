using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Rooms.DTOs
{
    public class CardNumberDto
    {
        public int? Number { get; set; }
        public int PositionRow { get; set; }
        public int PositionCol { get; set; }
        public bool? IsMarked { get; set; }
    }
}
