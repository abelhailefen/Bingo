using Bingo.Core.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Contract.Command
{
    public record ClaimBingoCommand(long RoomId, long UserId) : IRequest<Response<bool>>;

}
