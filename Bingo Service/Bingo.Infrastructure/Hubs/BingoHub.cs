using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;
using Bingo.Core.Contract.Hub;

namespace Bingo.Infrastructure.Hubs;
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