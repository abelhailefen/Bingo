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
   public record BuyCardsCommand(
    long UserId, 
    long RoomId, 
    int Quantity, 
    List<int>? ChosenMasterCardIds = null
) : IRequest<Response<List<Card>>>;

}
