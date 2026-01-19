using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NpgsqlTypes;


namespace Bingo.Core.Entities.Enums
{
    public enum WinPatternEnum
    {
        Line = 0,
        FullHouse = 1,
        Blackout = 2
    }
}
