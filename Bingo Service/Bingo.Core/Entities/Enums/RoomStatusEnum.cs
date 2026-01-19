using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NpgsqlTypes;

namespace Bingo.Core.Entities.Enums
{
    public enum RoomStatusEnum
    {
        Waiting = 0,
        InProgress = 1,
        Completed = 2,
        Cancelled = 3
    }
}
