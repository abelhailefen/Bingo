using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Models
{
    public class CreateRoomRequest
    {
        public string RoomName { get; set; } = string.Empty;
        public long HostUserId { get; set; }
    }


}
