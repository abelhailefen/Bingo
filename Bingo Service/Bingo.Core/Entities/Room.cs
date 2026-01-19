using Bingo.Core.Entities.Enums;

namespace Bingo.Core.Entities;

public class Room
{
    public long RoomId { get; set; }
    public string RoomCode { get; set; } = null!;
    public string Name { get; set; } = null!;
    // Host properties removed
    public RoomStatusEnum Status { get; set; }
    public int MaxPlayers { get; set; }
    public decimal CardPrice { get; set; }
    public WinPatternEnum Pattern { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ScheduledStartTime { get; set; } // The missing column
    public DateTime? StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }

    // Navigation
    public ICollection<RoomPlayer> Players { get; set; } = new List<RoomPlayer>();
    public ICollection<Card> Cards { get; set; } = new List<Card>();
    public ICollection<CalledNumber> CalledNumbers { get; set; } = new List<CalledNumber>();
}