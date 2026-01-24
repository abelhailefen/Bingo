using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.Gameplay.Contract.Command;

public class CallNumberCommand : IRequest<Response<int>>
{
    public long RoomId { get; }
    public CallNumberCommand(long roomId) => RoomId = roomId;
}