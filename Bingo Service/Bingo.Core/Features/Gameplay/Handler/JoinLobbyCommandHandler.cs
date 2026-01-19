using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Features.Gameplay.DTOs;
using Bingo.Core.Features.Rooms.DTOs;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.Gameplay.Handler
{
    public class JoinLobbyCommandHandler : IRequestHandler<JoinLobbyCommand, Response<JoinLobbyResponse>>
    {
        private readonly IBingoRepository _repository;

        public JoinLobbyCommandHandler(IBingoRepository repository)
        {
            _repository = repository;
        }

        public async Task<Response<JoinLobbyResponse>> Handle(JoinLobbyCommand request, CancellationToken cancellationToken)
        {
            // 1. Find a waiting room using Repository Query
            var room = await _repository.GetAvailableRoom(cancellationToken);

            // 2. If no room exists, create a new one using Repository
            if (room == null)
            {
                room = new Room
                {
                    Name = "Global Lobby",
                    RoomCode = Guid.NewGuid().ToString()[..6].ToUpper(),
                    //HostUserId = request.UserId,
                    Status = RoomStatusEnum.Waiting,
                    MaxPlayers = 100,
                    CardPrice = 0,
                    CreatedAt = DateTime.UtcNow
                };
                await _repository.AddAsync(room);
                await _repository.SaveChanges();
            }

            // 3. Check if user is already a player in this room
            var player = await _repository.FindOneAsync<RoomPlayer>(rp =>
                rp.RoomId == room.RoomId && rp.UserId == request.UserId);

            if (player == null)
            {
                await _repository.AddAsync(new RoomPlayer
                {
                    RoomId = room.RoomId,
                    UserId = request.UserId,
                    JoinedAt = DateTime.UtcNow
                });
                await _repository.SaveChanges();
            }

            // 4. Get list of MasterCards already purchased in this room
            var takenCardIds = await _repository.GetTakenCards(room.RoomId, cancellationToken);

            return Response<JoinLobbyResponse>.Success(new JoinLobbyResponse(room.RoomId, takenCardIds));
        }
    }
}