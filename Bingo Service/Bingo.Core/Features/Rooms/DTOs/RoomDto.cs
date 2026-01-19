using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Rooms.DTOs
{
    public class RoomDto
    {
        public long RoomId { get; set; }
        public string Name { get; set; }
        public string RoomCode { get; set; }
        public int Status { get; set; }
        public List<int> CalledNumbers { get; set; }
        public List<CardDto> Cards { get; set; }
    }

}
