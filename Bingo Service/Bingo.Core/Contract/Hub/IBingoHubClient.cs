using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Contract.Hub
{
    public interface IBingoHubClient
    {
        Task PlayerJoined(long roomId, string username);
        Task PlayerLeft(long roomId, string username);
        Task GameStarted(long roomId);
        Task NumberDrawn(long roomId, int number);
        Task WinClaimed(long roomId, string username, string winType, decimal prize);
        Task GameEnded(long roomId, string message);
        Task CardSelectionChanged(int masterCardId, bool isLocked, long userId);
        Task PlayerCountUpdated(int count);
        Task RoomStatsUpdated(long roomId, int playerCount, decimal prizePool);
    }
}
