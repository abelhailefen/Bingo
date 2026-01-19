using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Features.Gameplay.DTOs;
using Bingo.Core.Models;
using MediatR;

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
        // 1. SAFETY CHECK: Ensure the User exists in the database.
        // This prevents the "fk_user" violation when using a hardcoded ID like 123.
        var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);

        if (user == null)
        {
            // Auto-create user for development/demo purposes
            user = new User
            {
                UserId = request.UserId,
                Username = $"Player_{request.UserId}",
                PhoneNumber = request.UserId.ToString(),
                PasswordHash = "dev_bypass", // In production, this is handled by Auth logic
                Balance = 1000,
                CreatedAt = DateTime.UtcNow
            };
            await _repository.AddAsync(user);
            // We save immediately to ensure the User record exists before adding to RoomPlayers
            await _repository.SaveChanges();
        }

        // 2. Find a waiting room
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
                // Game starts 2 minutes from now (for auto-start logic)
                ScheduledStartTime = DateTime.UtcNow.AddMinutes(2)
            };
            await _repository.AddAsync(room);
            await _repository.SaveChanges();
        }

        // 4. Register the player in the room if they aren't already there
        var player = await _repository.FindOneAsync<RoomPlayer>(rp =>
            rp.RoomId == room.RoomId && rp.UserId == request.UserId);

        if (player == null)
        {
            await _repository.AddAsync(new RoomPlayer
            {
                RoomId = room.RoomId,
                UserId = request.UserId,
                JoinedAt = DateTime.UtcNow,
                IsReady = false
            });
            await _repository.SaveChanges();
        }

        // 5. Get list of MasterCards already purchased/locked in this room
        // This ensures a late-joining player sees the correct grid state immediately
        var takenCardIds = await _repository.GetTakenCards(room.RoomId, cancellationToken);

        // Map to response
        var responseData = new JoinLobbyResponse(room.RoomId, takenCardIds);

        return Response<JoinLobbyResponse>.Success(responseData);
    }
}