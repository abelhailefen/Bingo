using Bingo.Core.Entities;
using Bingo.Core.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Contract.Query
{
    public class GetRoomByIdQuery : IRequest<Response<Room>>
    {
        public long RoomId { get; set; }
    }
}
