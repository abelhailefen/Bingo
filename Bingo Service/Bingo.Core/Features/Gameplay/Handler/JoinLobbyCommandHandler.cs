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
    private static readonly SemaphoreSlim _semaphore = new SemaphoreSlim(1, 1);
    public JoinLobbyCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<JoinLobbyResponse>> Handle(JoinLobbyCommand request, CancellationToken cancellationToken)
    {
        await _semaphore.WaitAsync(cancellationToken);
        try
        {
            // 1. User Safety Check (Keep your existing logic...)
            var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);
            if (user == null) { /* ... create user ... */ }

            // 2. Find a room that is currently Waiting for this price
            var room = await _repository.FindOneAsync<Room>(r =>
                r.CardPrice == request.CardPrice && r.Status == RoomStatusEnum.Waiting);

            // 3. If no Waiting room exists, check if we need to create one 
            // (even if another one is InProgress, we create the "Next Game" lobby)
            if (room == null)
            {
                room = new Room
                {
                    Name = $"{request.CardPrice} Birr Public Room",
                    RoomCode = Guid.NewGuid().ToString()[..6].ToUpper(),
                    Status = RoomStatusEnum.Waiting,
                    MaxPlayers = 100,
                    CardPrice = request.CardPrice,
                    Pattern = WinPatternEnum.Line,
                    CreatedAt = DateTime.UtcNow,
                    // We set a far start time or null if we want to wait for the previous game
                    ScheduledStartTime = DateTime.UtcNow.AddSeconds(45)
                };
                await _repository.AddAsync(room);
                await _repository.SaveChanges();
            }

            // 4. Register Player (Keep your existing logic...)
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

            // 5. Check if the previous game is still running to inform the UI

            var takenCards = await _repository.GetTakenCards(room.RoomId, cancellationToken);

            // We add a 'Status' or 'Message' to the response if needed
            var responseData = new JoinLobbyResponse(room.RoomId, takenCards, room.ScheduledStartTime);

            return Response<JoinLobbyResponse>.Success(responseData);
        }
        finally
        {
            _semaphore.Release();
        }
    }
}