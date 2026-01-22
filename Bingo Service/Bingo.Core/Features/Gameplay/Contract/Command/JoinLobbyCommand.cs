using Bingo.Core.Models;
using Bingo.Core.Features.Gameplay.DTOs;
using MediatR;

namespace Bingo.Core.Features.Gameplay.Contract.Command
{
    public class JoinLobbyCommand : IRequest<Response<JoinLobbyResponse>>
    {
        public long UserId { get; }
        public decimal CardPrice { get; }
        public JoinLobbyCommand(long userId, decimal cardPrice)
        {
            UserId = userId;
            CardPrice = cardPrice;
        } 
    }
}