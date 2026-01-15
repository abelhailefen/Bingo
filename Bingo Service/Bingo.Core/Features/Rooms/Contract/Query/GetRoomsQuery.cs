using MediatR;
using Bingo.Core.Models;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;

namespace Bingo.Core.Features.Rooms.Contract.Query;

public record GetRoomsQuery(RoomStatusEnum? Status = null) : IRequest<Response<List<RoomSummaryDto>>>;

public class RoomSummaryDto
{
    public long RoomId { get; set; }
    public string RoomCode { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public RoomStatusEnum Status { get; set; }
    public int PlayerCount { get; set; }
    public int MaxPlayers { get; set; }
    public decimal CardPrice { get; set; }
}
