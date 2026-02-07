using Bingo.Core.Contract.Hub;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Hubs;
using Bingo.Core.Models;
using Bingo.Core.Services;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Handler
{
    public class ClaimBingoCommandHandler : IRequestHandler<ClaimBingoCommand, Response<bool>>
    {
        private readonly IBingoRepository _repository;
        private readonly IMediator _mediator;

        public ClaimBingoCommandHandler(IBingoRepository repository, IMediator mediator)
        {
            _repository = repository;
            _mediator = mediator;
        }

        public async Task<Response<bool>> Handle(ClaimBingoCommand request, CancellationToken cancellationToken)
        {
            var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
            if (room == null) return Response<bool>.Error("Room not found.");
            if (room.Status != RoomStatusEnum.InProgress) return Response<bool>.Error("Game is not currently active.");

            var calledNumbers = (await _repository.FindAsync<CalledNumber>(cn => cn.RoomId == request.RoomId))
                                .Select(cn => cn.Number).ToList();

            var userCards = await _repository.GetUserCardsInRoomAsync(request.UserId, request.RoomId);

            if (userCards == null || !userCards.Any())
                return Response<bool>.Error("No cards found for this user in this room.");

            Card winningCard = null;
            WinPatternEnum detectedPattern = room.Pattern; 

            foreach (var card in userCards)
            {
                // Ensure we have exactly 25 numbers ordered correctly
                var flatNumbers = card.MasterCard.Numbers
                    .OrderBy(n => n.PositionRow)
                    .ThenBy(n => n.PositionCol)
                    .Select(n => n.Number ?? 0)
                    .ToList();

                // Note: WinVerificationService.IsValidWin likely checks for 'Line' or generic Bingo. 
                // We should ideally check against the Room's specific Pattern (e.g. FullHouse).
                // Assuming IsValidWin checks basic Line/Bingo logic for now. 
                // TODO: Update WinVerificationService to support patterns or use Repository.VerifyWinAsync here too?
                // For consistency with Bot logic, let's use Repository VerifyWinAsync!
                
                if (await _repository.VerifyWinAsync(card.CardId, room.Pattern))
                {
                    winningCard = card;
                    break;
                }
            }

            if (winningCard == null)
                return Response<bool>.Error("Wait! Your card doesn't have a Bingo yet. Keep playing!");

            // Delegate to ClaimWinCommand
            var claimResult = await _mediator.Send(new ClaimWinCommand(
                request.RoomId, 
                request.UserId, 
                winningCard.CardId, 
                (WinTypeEnum)room.Pattern 
            ), cancellationToken);

            if (claimResult.ResponseStatus != ResponseStatus.Success )
            {
                return Response<bool>.Error(claimResult.Message);
            }

            return Response<bool>.Success(true);
        }
    }
}
