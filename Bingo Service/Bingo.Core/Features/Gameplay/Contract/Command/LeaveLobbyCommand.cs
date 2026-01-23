// File: Bingo.Core/Features/Gameplay/Contract/Command/LeaveLobbyCommand.cs
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Gameplay.Contract.Command;

public record LeaveLobbyCommand(long RoomId, long UserId) : IRequest<Response<bool>>;