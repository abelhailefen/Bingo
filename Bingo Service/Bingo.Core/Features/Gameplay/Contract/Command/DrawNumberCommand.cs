using MediatR;
using Bingo.Core.Models;
using Bingo.Core.Entities;

namespace Bingo.Core.Features.Gameplay.Contract.Command;

public record DrawNumberCommand(long RoomId, long UserId) : IRequest<Response<short>>;
