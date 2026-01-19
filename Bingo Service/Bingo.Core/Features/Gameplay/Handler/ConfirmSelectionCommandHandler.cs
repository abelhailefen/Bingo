using Bingo.Core.Contract.Repository;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Handler
{
    public class ConfirmSelectionCommandHandler : IRequestHandler<ConfirmSelectionCommand, Response<string>>
    {
        private readonly IBingoRepository _repository;

        public ConfirmSelectionCommandHandler(IBingoRepository repository)
        {
            _repository = repository;
        }

        public async Task<Response<string>> Handle(ConfirmSelectionCommand request, CancellationToken cancellationToken)
        {
            if (request.MasterCardIds.Count == 0 || request.MasterCardIds.Count > 2)
                return Response<string>.Error("You must select between 1 and 2 cards.");

            foreach (var cardId in request.MasterCardIds)
            {
                // Repository method provided in your snippet:
                await _repository.PickMasterCardAsync(request.UserId, request.RoomId, cardId);
            }

            return Response<string>.Success("Cards confirmed. Entering game.");
        }
    }
}
