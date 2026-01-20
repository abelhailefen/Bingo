using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.Rooms.Contract.Query;

public record GetTakenCardsQuery(long RoomId) : IRequest<Response<List<int>>>;