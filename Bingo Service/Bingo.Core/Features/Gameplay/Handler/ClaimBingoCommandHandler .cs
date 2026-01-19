using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
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
    public class ClaimBingoCommandHandler : IRequestHandler<ClaimBingoCommand, Response<bool>>
    {
        private readonly IBingoRepository _repository;

        public ClaimBingoCommandHandler(IBingoRepository repository)
        {
            _repository = repository;
        }

        public async Task<Response<bool>> Handle(ClaimBingoCommand request, CancellationToken ct)
        {
            // 1. Get user's cards in this room
            var cards = await _repository.GetUserCardsInRoomAsync(request.UserId, request.RoomId);

            // 2. Use your existing VerifyWinAsync logic
            foreach (var card in cards)
            {
                // Check for a win (you can pass different patterns based on room settings)
                bool isWinner = await _repository.VerifyWinAsync(card.CardId, WinPatternEnum.Line);

                if (isWinner)
                {
                    // Record the win in the DB
                    await _repository.RecordWinAsync(new Win
                    {
                        RoomId = request.RoomId,
                        UserId = request.UserId,
                        CardId = card.CardId,
                        Verified = true,
                        ClaimedAt = DateTime.UtcNow
                    });
                    return Response<bool>.Success(true);
                }
            }

            return Response<bool>.Error("No winning pattern found on your cards.");
        }
    }
}
