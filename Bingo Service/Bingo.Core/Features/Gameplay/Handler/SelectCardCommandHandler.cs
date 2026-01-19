using Bingo.Core.Contract.Hub;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Models;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using Bingo.Core.Hubs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Handler
{
    public class SelectCardCommandHandler : IRequestHandler<SelectCardCommand, Response<bool>>
    {
        private readonly IBingoRepository _repository;
        private readonly IHubContext<BingoHub, IBingoHubClient> _hubContext;

        public SelectCardCommandHandler(IBingoRepository repository, IHubContext<BingoHub, IBingoHubClient> hubContext)
        {
            _repository = repository;
            _hubContext = hubContext;
        }

        public async Task<Response<bool>> Handle(SelectCardCommand request, CancellationToken ct)
        {
            if (request.IsSelecting)
            {
                // 1. Check if card is already taken by ANYONE
                var isTaken = await _repository.CountAsync<Card>(c =>
                    c.RoomId == request.RoomId && c.MasterCardId == request.MasterCardId) > 0;

                if (isTaken) return Response<bool>.Error("Card already taken.");

                // 2. Check if user already has 2 cards
                var userCardCount = await _repository.CountAsync<Card>(c =>
                    c.RoomId == request.RoomId && c.UserId == request.UserId);

                if (userCardCount >= 2) return Response<bool>.Error("Max 2 cards allowed.");

                // 3. Persist the selection
                await _repository.PickMasterCardAsync(request.UserId, request.RoomId, request.MasterCardId);
            }
            else
            {
                // Unselect: Remove the card record
                await _repository.DeleteAsync<Card>(c =>
                    c.RoomId == request.RoomId && c.UserId == request.UserId && c.MasterCardId == request.MasterCardId);
                await _repository.SaveChanges();
            }

            // 4. Notify everyone in the room via SignalR
            // We broadcast: RoomId, MasterCardId, IsLocked (IsSelecting), and who did it
            await _hubContext.Clients.Group(request.RoomId.ToString())
                .CardSelectionChanged(request.MasterCardId, request.IsSelecting, (int)request.UserId);

            return Response<bool>.Success(true);
        }
    }
}
