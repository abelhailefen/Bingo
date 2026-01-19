using Bingo.Core.Features.Rooms.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.DTOs
{
    public class MasterCardDto
    {
        public long MasterCardId { get; set; }
        public List<CardNumberDto> Numbers { get; set; } = new();
        public bool IsAvailable { get; set; }
    }
}
