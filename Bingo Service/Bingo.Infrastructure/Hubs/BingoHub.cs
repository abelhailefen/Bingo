// Bingo.Infrastructure.Hubs/BingoHub.cs
using Microsoft.AspNetCore.SignalR;
using System.Text.RegularExpressions;

public class BingoHub : Hub
{
    public async Task JoinRoomGroup(string roomCode) => await Groups.AddToGroupAsync(Context.ConnectionId, roomCode);
}

// Number Calling Service (Pseudo-code)
public class BingoGameWorker
{
    private readonly IHubContext<BingoHub> _hubContext;
    // Every 5 seconds:
    // 1. Pick random number (1-75)
    // 2. Save to DB (CalledNumbers)
    // 3. _hubContext.Clients.Group(roomCode).SendAsync("NewNumber", number);
}