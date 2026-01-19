using Bingo.Core.Models;
using Bingo.Core.Features.Gameplay.DTOs;
using MediatR;

namespace Bingo.Core.Features.Gameplay.Contract.Command
{
    public class JoinLobbyCommand : IRequest<Response<JoinLobbyResponse>>
    {
        public long UserId { get; }
        public JoinLobbyCommand(long userId) => UserId = userId;
    }
}