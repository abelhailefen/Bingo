using MediatR;
using Bingo.Core.Models;
using Bingo.Core.Entities;

namespace Bingo.Core.Features.Rooms.Contract.Query;

public record GetRoomDetailsQuery(long RoomId) : IRequest<Response<Room>>;
