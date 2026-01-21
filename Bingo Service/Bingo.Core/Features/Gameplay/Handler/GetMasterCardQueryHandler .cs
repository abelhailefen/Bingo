using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Features.Gameplay.Contract.Query;
using Bingo.Core.Features.Gameplay.DTOs;
using Bingo.Core.Features.Rooms.DTOs;
using Bingo.Core.Models;
using MediatR;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Handler
{
    public class GetMasterCardQueryHandler : IRequestHandler<GetMasterCardQuery, Response<MasterCardDto>>
    {
        private readonly IBingoRepository _repository;

        public GetMasterCardQueryHandler(IBingoRepository repository)
        {
            _repository = repository;
        }

        public async Task<Response<MasterCardDto>> Handle(GetMasterCardQuery request, CancellationToken cancellationToken)
        {
            // 1. Get the Master Template

            var masterCard = await _repository.GetMasterCard(request.MasterCardId, cancellationToken);

            if (masterCard == null) return Response<MasterCardDto>.NotFound("Template not found");

           
            // 3. Map to DTO
            var dto = new MasterCardDto
            {
                MasterCardId = masterCard.MasterCardId,
                IsAvailable = true,
                Numbers = masterCard.Numbers
                    // CRITICAL: Sort by Row first, then Column for CSS Grid Row-Major layout
                    .OrderBy(n => n.PositionRow)
                    .ThenBy(n => n.PositionCol)
                    .Select(n => new CardNumberDto
                    {
                        Number = n.Number,
                        PositionRow = n.PositionRow,
                        PositionCol = n.PositionCol,
                        IsMarked = n.Number == null
                    }).ToList()
            };

            return Response<MasterCardDto>.Success(dto);
        }
    }
}
