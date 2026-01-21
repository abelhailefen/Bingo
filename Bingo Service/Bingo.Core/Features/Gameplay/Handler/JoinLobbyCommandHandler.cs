using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Features.Gameplay.DTOs;
using Bingo.Core.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Handler;

public class JoinLobbyCommandHandler : IRequestHandler<JoinLobbyCommand, Response<JoinLobbyResponse>>
{
    private readonly IBingoRepository _repository;

    public JoinLobbyCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<JoinLobbyResponse>> Handle(JoinLobbyCommand request, CancellationToken cancellationToken)
    {
        try
        {
            // 1. SAFETY CHECK: Ensure the User exists in the database.
            // Handles both Telegram users and Dev/Guest mode users.
            var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);

            if (user == null)
            {
                user = new User
                {
                    UserId = request.UserId,
                    Username = $"Player_{request.UserId}",
                    PhoneNumber = request.UserId.ToString(),
                    PasswordHash = "dev_bypass",
                    Balance = 1000,
                    CreatedAt = DateTime.UtcNow
                };
                await _repository.AddAsync(user);
                // Save immediately so the UserId is valid for foreign keys in subsequent steps
                await _repository.SaveChanges();
            }

            // 2. Find a waiting room (Status = Waiting)
            var room = await _repository.GetAvailableRoom(cancellationToken);

            // 3. If no room exists, create a new System-managed room
            if (room == null)
            {
                room = new Room
                {
                    Name = "Public Bingo Room",
                    RoomCode = Guid.NewGuid().ToString()[..6].ToUpper(),
                    Status = RoomStatusEnum.Waiting,
                    MaxPlayers = 100,
                    CardPrice = 10.00m,
                    Pattern = WinPatternEnum.Line,
                    CreatedAt = DateTime.UtcNow,
                    ScheduledStartTime = DateTime.UtcNow.AddMinutes(2)
                };
                await _repository.AddAsync(room);
                await _repository.SaveChanges();
            }

            // 4. Register the player in the room.
            // FIX: We check for existence first to avoid "duplicate key value" Postgres error (Constraint: room_players_room_id_user_id_key)
            var existingPlayer = await _repository.FindOneAsync<RoomPlayer>(rp =>
                rp.RoomId == room.RoomId && rp.UserId == request.UserId);

            if (existingPlayer == null)
            {
                await _repository.AddAsync(new RoomPlayer
                {
                    RoomId = room.RoomId,
                    UserId = request.UserId,
                    JoinedAt = DateTime.UtcNow,
                    IsReady = false
                });
                // Commit the room participation
                await _repository.SaveChanges();
            }

            // 5. Fetch all cards already taken in this room.
            // This allows the frontend to grey out buttons immediately upon entry.
            var takenCards = await _repository.GetTakenCards(room.RoomId, cancellationToken);

            // 6. Map to DTO
            var responseData = new JoinLobbyResponse(room.RoomId, takenCards);


            return Response<JoinLobbyResponse>.Success(responseData);
        }
        catch (Exception ex)
        {
            // Log this error in your logging system
            return Response<JoinLobbyResponse>.Error($"Failed to join lobby: {ex.Message}");
        }
    }
}