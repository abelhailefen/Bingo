using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Features.Gameplay.Contract.Query;
using Bingo.Core.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Handler
{
    public class GetRoomByIdQueryHandler : IRequestHandler<GetRoomByIdQuery, Response<Room>>
    {
        IBingoRepository _repo;
        public GetRoomByIdQueryHandler(IBingoRepository repo)
        {
            _repo = repo;
        }
        public async Task<Response<Room>> Handle (GetRoomByIdQuery query, CancellationToken ct)
        {
            try
            {
                var room = await _repo.GetRoomById(query.RoomId);

                return Response<Room>.Success(room);
            }catch (Exception ex)
            {
                return Response<Room>.Error(ex.Message);
            }
        }
    }
}
