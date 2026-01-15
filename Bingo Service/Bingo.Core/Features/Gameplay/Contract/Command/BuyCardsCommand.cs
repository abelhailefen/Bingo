using Bingo.Core.Entities;
using Bingo.Core.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Gameplay.Contract.Command
{
    public record BuyCardsCommand(int UserId, int RoomId, int Quantity) : IRequest<Response<List<Card>>>;

}
