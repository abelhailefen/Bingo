using MediatR;
using Bingo.Core.Models;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Entities;

namespace Bingo.Core.Features.Gameplay.Contract.Command;

public record ClaimWinCommand(
    long RoomId,
    long UserId,
    long CardId,
    WinTypeEnum WinType
) : IRequest<Response<Win>>;
