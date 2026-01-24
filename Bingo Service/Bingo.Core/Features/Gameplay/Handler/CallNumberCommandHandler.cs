using Bingo.Core.Contract.Hub;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Hubs;
using Bingo.Core.Models;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using System.Linq;


namespace Bingo.Core.Features.Gameplay.Handler;

public class CallNumberCommandHandler : IRequestHandler<CallNumberCommand, Response<int>>
{
    private readonly IBingoRepository _repository;
    private readonly IHubContext<BingoHub, IBingoHubClient> _hubContext;
    private static readonly Random _random = new();

    public CallNumberCommandHandler(IBingoRepository repository, IHubContext<BingoHub, IBingoHubClient> hubContext)
    {
        _repository = repository;
        _hubContext = hubContext;
    }

    public async Task<Response<int>> Handle(CallNumberCommand request, CancellationToken cancellationToken)
    {
        // 1. Get room and existing numbers
        var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
        if (room == null || room.Status != RoomStatusEnum.InProgress)
            return Response<int>.Error("Room is not in progress.");

        var alreadyCalled = await _repository.FindAsync<CalledNumber>(cn => cn.RoomId == request.RoomId);
        var calledValues = alreadyCalled.Select(c => c.Number).ToHashSet();

        if (calledValues.Count >= 75)
            return Response<int>.Error("All numbers have been called.");

        // 2. Pick a random number not yet called
        int nextNumber;
        do
        {
            nextNumber = _random.Next(1, 76);
        } while (calledValues.Contains(nextNumber));

        // 3. Save to Database
        var calledNumber = new CalledNumber
        {
            RoomId = (int)request.RoomId,
            Number = nextNumber,
            CalledAt = DateTime.UtcNow
        };

        await _repository.AddAsync(calledNumber);
        await _repository.SaveChanges();

        // 4. Broadcast via SignalR
        // Note: Using the typed client interface defined in your contract
        await _hubContext.Clients.Group(request.RoomId.ToString())
            .NumberDrawn(request.RoomId, nextNumber);

        return Response<int>.Success(nextNumber);
    }
}