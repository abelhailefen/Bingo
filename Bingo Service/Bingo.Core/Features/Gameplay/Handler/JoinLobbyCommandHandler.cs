using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Features.Gameplay.Contract.Service;
using Bingo.Core.Features.Gameplay.DTOs;
using Bingo.Core.Models;
using MediatR;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Bingo.Core.Features.Gameplay.Handler;

public class JoinLobbyCommandHandler : IRequestHandler<JoinLobbyCommand, Response<JoinLobbyResponse>>
{
    private readonly IBingoRepository _repository;
    private readonly ILogger<JoinLobbyCommandHandler> _logger;  

    private static readonly SemaphoreSlim _semaphore = new SemaphoreSlim(1, 1);
    public JoinLobbyCommandHandler(IBingoRepository repository,  ILogger<JoinLobbyCommandHandler> logger)
    {
        _repository = repository;
        _logger = logger;

    }
    public async Task<Response<JoinLobbyResponse>> Handle(JoinLobbyCommand request, CancellationToken cancellationToken)
    {
        await _semaphore.WaitAsync(cancellationToken);
        _logger.LogInformation("User {UserId} is attempting to join a lobby for card price {CardPrice}", request.UserId, request.CardPrice);
   

        try
        {

            // 1. Find the ONLY active waiting room for this price
            var room = await _repository.FindOneAsync<Room>(r =>
                r.CardPrice == request.CardPrice &&
                r.Status == RoomStatusEnum.Waiting);

            // STRICT EXCLUSION: If the countdown has already hit zero, consider this room closed for new players.
            // UNLESS there's an InProgress game, meaning this room is just waiting in queue.
            if (room != null && room.ScheduledStartTime.HasValue && room.ScheduledStartTime.Value <= DateTime.UtcNow)
            {
                bool priceIsBusy = await _repository.AnyAsync<Room>(r => r.CardPrice == request.CardPrice && r.Status == RoomStatusEnum.InProgress);
                if (!priceIsBusy)
                {
                    room = null;
                }
            }

            // 2. If no Waiting room exists, check if there is one InProgress.
            // If your business rule is "One game at a time", we only create a 
            // new Waiting room if there isn't an InProgress one, OR we create 
            // it as a "Queue" for the next game.
            if (room == null)
            {
                // Optional: Check if an InProgress room exists to decide on ScheduledStartTime
                var inProgressRoom = await _repository.FindOneAsync<Room>(r =>
                    r.CardPrice == request.CardPrice && r.Status == RoomStatusEnum.InProgress);

                room = new Room
                {
                    Name = $"{request.CardPrice} Birr Public Room",
                    RoomCode = Guid.NewGuid().ToString()[..6].ToUpper(),
                    Status = RoomStatusEnum.Waiting,
                    MaxPlayers = 100,
                    CardPrice = request.CardPrice,
                    Pattern = WinPatternEnum.Line,
                    CreatedAt = DateTime.UtcNow,
                    // Default 30 seconds countdown (will be extended if blocked by another game)
                    ScheduledStartTime = DateTime.UtcNow.AddSeconds(40)
                };
                await _repository.AddAsync(room);
                await _repository.SaveChanges();

            }

            // 2.5 DEFENSIVE: Ensure User exists before adding to room_players
            // This prevents FK violations if auth didn't create the user
            var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);
            if (user == null)
            {
                return Response<JoinLobbyResponse>.Error($"User {request.UserId} not found. Please authenticate first.");
            }

            // 3. IMPORTANT: Ensure the player is linked to THIS specific room.
            // We check RoomId AND UserId to ensure we aren't looking at old Completed rooms.
            var existingPlayer = await _repository.FindOneAsync<RoomPlayer>(rp =>
                rp.RoomId == room.RoomId && rp.UserId == request.UserId);

            if (existingPlayer == null)
            {
                await _repository.AddAsync(new RoomPlayer
                {
                    RoomId = room.RoomId,
                    UserId = request.UserId,
                    JoinedAt = DateTime.UtcNow
                });
                await _repository.SaveChanges();
            }

            var takenCards = await _repository.GetTakenCards(room.RoomId, cancellationToken);
            var responseData = new JoinLobbyResponse(room.RoomId, takenCards, room.ScheduledStartTime);

            return Response<JoinLobbyResponse>.Success(responseData);
        }
        finally
        {
            _semaphore.Release();
        }
    }
}