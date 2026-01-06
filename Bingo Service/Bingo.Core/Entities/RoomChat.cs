using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Entities
{
    public class RoomChat
    {
        public long MessageId { get; set; }
        public long RoomId { get; set; }
        public long UserId { get; set; }
        public string Message { get; set; } = null!;
        public DateTime SentAt { get; set; }
    }
}
