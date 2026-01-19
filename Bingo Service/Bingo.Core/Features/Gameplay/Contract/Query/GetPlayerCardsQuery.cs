using Bingo.Core.Entities;
using Bingo.Core.Features.Rooms.DTOs;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.Gameplay.Contract.Query;

public record GetPlayerCardsQuery(long RoomId, long UserId) : IRequest<Response<List<CardDto>>>;
