using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;
using Bingo.Core.Contract.Hub;

namespace Bingo.Core.Hubs;
public class BingoHub : Hub<IBingoHubClient>
{
    public async Task JoinRoomGroup(string roomId)
    {
        // Add logging to see if this is actually hit
        Console.WriteLine($"[SignalR] Connection {Context.ConnectionId} joining room: {roomId}");
        await Groups.AddToGroupAsync(Context.ConnectionId, roomId);
    }

    public async Task LeaveRoomGroup(string roomId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, roomId);
    }

}