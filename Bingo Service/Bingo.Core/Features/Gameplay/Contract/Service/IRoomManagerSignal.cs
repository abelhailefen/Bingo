using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Channels;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Contract.Service
{
    public interface IRoomManagerSignal
    {
        ValueTask SignalNewRoom(long roomId, decimal cardPrice);
        ChannelReader<(long RoomId, decimal CardPrice)> Reader { get; }
    }
}
