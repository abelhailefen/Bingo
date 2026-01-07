using MediatR;
using Bingo.Core.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Bingo.Core.Entities;

namespace Bingo.Core.BingoGame.Contract.Command
{
    public class JoinGameCommand : IRequest<Response<Room>>
    {

    }
}
