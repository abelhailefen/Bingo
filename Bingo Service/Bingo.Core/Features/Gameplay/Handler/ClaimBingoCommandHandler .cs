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
        private readonly IHubContext<BingoHub, IBingoHubClient> _hubContext;

        public ClaimBingoCommandHandler(IBingoRepository repository, IHubContext<BingoHub, IBingoHubClient> hubContext)
        {
            _repository = repository;
            _hubContext = hubContext;
        }

        public async Task<Response<bool>> Handle(ClaimBingoCommand request, CancellationToken cancellationToken)
        {
            var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
            if (room == null) return Response<bool>.Error("Room not found.");
            if (room.Status != RoomStatusEnum.InProgress) return Response<bool>.Error("Game is not currently active.");

            var calledNumbers = (await _repository.FindAsync<CalledNumber>(cn => cn.RoomId == request.RoomId))
                                .Select(cn => cn.Number).ToList();

            // FIX 1: Corrected Argument Order (UserId, RoomId)
            var userCards = await _repository.GetUserCardsInRoomAsync(request.UserId, request.RoomId);

            if (userCards == null || !userCards.Any())
                return Response<bool>.Error("No cards found for this user in this room.");

            Card winningCard = null;
            foreach (var card in userCards)
            {
                // Ensure we have exactly 25 numbers ordered correctly
                var flatNumbers = card.MasterCard.Numbers
                    .OrderBy(n => n.PositionRow)
                    .ThenBy(n => n.PositionCol)
                    .Select(n => n.Number ?? 0)
                    .ToList();

                if (WinVerificationService.IsValidWin(flatNumbers, calledNumbers))
                {
                    winningCard = card;
                    break;
                }
            }

            if (winningCard == null)
                return Response<bool>.Error("Wait! Your card doesn't have a Bingo yet. Keep playing!");

            var playerCount = await _repository.CountAsync<RoomPlayer>(rp => rp.RoomId == request.RoomId);

            // 1. Record the Win
            var win = new Win
            {
                RoomId = (int)request.RoomId,
                UserId = request.UserId,
                CardId = winningCard.CardId,
                WinType = WinTypeEnum.Line,
                Prize = room.CardPrice * playerCount * 0.87m,
                Verified = true
            };

            await _repository.AddAsync(win);
            room.Status = RoomStatusEnum.Completed;
            await _repository.UpdateAsync(room);
            await _repository.SaveChanges();

            var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);
            await _hubContext.Clients.Group(request.RoomId.ToString())
                .WinClaimed(request.RoomId, user.Username, "LINE BINGO", win.Prize);

            return Response<bool>.Success(true);
        }
    }
}
