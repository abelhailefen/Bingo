using MediatR;
using Bingo.Core.Models;

namespace Bingo.Core.Features.Rooms.Contract.Command;

public record JoinRoomCommand(long RoomId, long UserId) : IRequest<Response<string>>;
