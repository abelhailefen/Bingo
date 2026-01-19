using Bingo.Core.Features.Gameplay.DTOs;
using Bingo.Core.Models;
using MediatR;   
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Contract.Query
{
    public record GetMasterCardQuery(long RoomId, int MasterCardId) : IRequest<Response<MasterCardDto>>;

}
