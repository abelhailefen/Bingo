using Bingo.Core.Entities;
using Bingo.Core.Features.Rooms.DTOs;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.Rooms.Contract.Query;

public record GetRoomDetailsQuery(long RoomId) : IRequest<Response<RoomDto>>;
