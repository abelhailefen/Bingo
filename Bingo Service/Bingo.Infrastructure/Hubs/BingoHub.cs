using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace Bingo.Infrastructure.Hubs;

public interface IBingoHubClient
{
    Task PlayerJoined(long roomId, string username);
    Task PlayerLeft(long roomId, string username);
    Task GameStarted(long roomId);
    Task NumberDrawn(long roomId, int number);
    Task WinClaimed(long roomId, string username, string winType, decimal prize);
    Task GameEnded(long roomId);
}

public class BingoHub : Hub<IBingoHubClient>
{
    public async Task JoinRoomGroup(string roomId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, roomId);
    }

    public async Task LeaveRoomGroup(string roomId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, roomId);
    }
}