using MediatR;
using Bingo.Core.Models;
using Bingo.Core.Entities.Enums;

namespace Bingo.Core.Features.Rooms.Contract.Command;

public record CreateRoomCommand(
    long HostUserId,
    string Name,
    int MaxPlayers,
    decimal CardPrice,
    WinPatternEnum Pattern
) : IRequest<Response<CreateRoomResponse>>;

public record CreateRoomResponse(long RoomId, string RoomCode);
