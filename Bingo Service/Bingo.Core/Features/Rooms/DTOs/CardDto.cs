using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Rooms.DTOs
{
    public class CardDto
    {
        public long CardId { get; set; }
        public long UserId { get; set; }
        public List<CardNumberDto> Numbers { get; set; }
    }
}
