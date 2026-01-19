using MediatR;
using Bingo.Core.Models;
using Bingo.Core.Entities;
using Bingo.Core.Features.Rooms.Contract.Query;
using Bingo.Core.Entities.Enums;

namespace Bingo.Core.Features.Gameplay.Contract.Query;

public record GetRoomStateQuery(long RoomId) : IRequest<Response<RoomStateDto>>;

public class RoomStateDto
{
    public long RoomId { get; set; }
    public RoomStatusEnum Status { get; set; }
    public List<int> CalledNumbers { get; set; } = new();
    public List<string> Players { get; set; } = new(); // Just names for lightweight state? Or count?
                                                       // Prompt says "including called_numbers, room_players, wins"
    public int PlayerCount { get; set; }
    public List<WinSummaryDto> Wins { get; set; } = new();
}

public class WinSummaryDto
{
    public long WinId { get; set; }
    public string Username { get; set; } = string.Empty;
    public decimal Prize { get; set; }
    public string WinType { get; set; } = string.Empty;
}
