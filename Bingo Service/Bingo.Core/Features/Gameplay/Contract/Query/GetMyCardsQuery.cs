using Bingo.Core.Entities;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.Gameplay.Contract.Query;

public record GetMyCardsQuery(long RoomId, long UserId) : IRequest<Response<List<Card>>>;