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
            var calledNumbers = (await _repository.FindAsync<CalledNumber>(cn => cn.RoomId == request.RoomId))
                                .Select(cn => cn.Number).ToList();

            // Get all cards for this user in this room
            var userCards = await _repository.GetUserCardsInRoomAsync(request.RoomId, request.UserId);
            var winningCard = userCards.FirstOrDefault(card =>
                WinVerificationService.IsValidWin(card.MasterCard.Numbers.OrderBy(n => n.PositionRow).ThenBy(n => n.PositionCol)
                .Select(n => n.Number ?? 0).ToList(), calledNumbers));

            if (winningCard == null)
                return Response<bool>.Error("No valid Bingo found on your cards.");

            // 1. Record the Win
            var win = new Win
            {
                RoomId = (int)request.RoomId,
                UserId = request.UserId,
                CardId = winningCard.CardId,
                WinType = WinTypeEnum.Line,
                Prize = room.CardPrice * room.MaxPlayers * 0.8m, // Example prize logic
                Verified = true
            };
            await _repository.AddAsync(win);

            // 2. End the Game
            room.Status = RoomStatusEnum.Completed;
            await _repository.UpdateAsync(room);
            await _repository.SaveChanges();

            // 3. Broadcast to all users
            var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);
            await _hubContext.Clients.Group(request.RoomId.ToString())
                .WinClaimed(request.RoomId, user.Username, "LINE BINGO", win.Prize);

            return Response<bool>.Success(true);
        }
    }
}
