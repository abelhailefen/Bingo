using MediatR;
using Bingo.Core.Models;
using Bingo.Core.Entities;

namespace Bingo.Core.Features.Gameplay.Contract.Query;

public record GetPlayerCardsQuery(long RoomId, long UserId) : IRequest<Response<List<Card>>>;
