using Bingo.Core.Features.Gameplay.Contract.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Channels;
using System.Threading.Tasks;

namespace Bingo.Core.Services
{
    public class RoomManagerSignal : IRoomManagerSignal
    {
        // Unbounded channel to ensure we don't block the API request
        private readonly Channel<(long RoomId, decimal CardPrice)> _channel = Channel.CreateUnbounded<(long RoomId, decimal CardPrice)>();

        public ChannelReader<(long RoomId, decimal CardPrice)> Reader => _channel.Reader;

        public async ValueTask SignalNewRoom(long roomId, decimal cardPrice)
        {
            await _channel.Writer.WriteAsync((roomId, cardPrice));
        }
    }

}
