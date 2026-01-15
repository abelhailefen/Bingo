using MediatR;
using Bingo.Core.Models;

namespace Bingo.Core.Features.Admin.Contract.Query;

public record GetSystemStatsQuery() : IRequest<Response<SystemStatsDto>>;

public class SystemStatsDto
{
    public int ActiveRooms { get; set; }
    public int TotalPlayers { get; set; }
    public int TotalGamesPlayed { get; set; }
}
