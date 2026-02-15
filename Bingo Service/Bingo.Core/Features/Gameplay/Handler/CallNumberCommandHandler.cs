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

namespace Bingo.Core.Features.Gameplay.Handler;

public class CallNumberCommandHandler : IRequestHandler<CallNumberCommand, Response<int>>
{
    private readonly IBingoRepository _repository;
    private readonly IHubContext<BingoHub, IBingoHubClient> _hubContext;
    private readonly BotPlayerService _botPlayerService;
    private static readonly Random _random = new();

    public CallNumberCommandHandler(
        IBingoRepository repository, 
        IHubContext<BingoHub, IBingoHubClient> hubContext,
        BotPlayerService botPlayerService)
    {
        _repository = repository;
        _hubContext = hubContext;
        _botPlayerService = botPlayerService;
    }

    public async Task<Response<int>> Handle(CallNumberCommand request, CancellationToken cancellationToken)
    {
        // 1. Get room and validate status
        var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
        if (room == null || room.Status != RoomStatusEnum.InProgress)
            return Response<int>.Error("Room is not in progress.");

        // 2. Get existing numbers to ensure uniqueness
        var alreadyCalledList = await _repository.FindAsync<CalledNumber>(cn => cn.RoomId == request.RoomId);
        var calledValues = alreadyCalledList.Select(c => c.Number).ToHashSet();

        if (calledValues.Count >= 75)
        {
            await EndGameAsCancelled(room, "All numbers exhausted.");
            return Response<int>.Error("All numbers have been called.");
        }

        // 3. Pick a random number (1-75)
        int nextNumber;
        do
        {
            nextNumber = _random.Next(1, 76);
        } while (calledValues.Contains(nextNumber));

        // 4. Persist the called number
        var calledNumber = new CalledNumber
        {
            RoomId = (int)request.RoomId,
            Number = nextNumber,
            CalledAt = DateTime.UtcNow
        };
        await _repository.AddAsync(calledNumber);

        // 5. Check if this is the final possible number
        bool isLastNumber = (calledValues.Count + 1) >= 75;
        if (isLastNumber)
        {
            room.Status = RoomStatusEnum.Cancelled;
            await _repository.UpdateAsync(room);
        }

        await _repository.SaveChanges();

        // 6. Broadcast the number to the group
        await _hubContext.Clients.Group(request.RoomId.ToString())
            .NumberDrawn(request.RoomId, nextNumber);

        // 6.5. Check if any bots have won with this number
        try
        {
            calledValues.Add(nextNumber);
            await _botPlayerService.CheckBotWinsAsync(request.RoomId, calledValues.ToList());
        }
        catch (Exception ex)
        {
            // Log but don't fail the whole operation if bot checking fails
            // (You may want to add proper logging here)
        }

        // 7. Broadcast Game Over if no more numbers are left
        if (isLastNumber)
        {
            await _hubContext.Clients.Group(request.RoomId.ToString())
                .GameEnded(request.RoomId, "Maximum calls reached. No winner.");
        }

        return Response<int>.Success(nextNumber);
    }

    private async Task EndGameAsCancelled(Room room, string reason)
    {
        room.Status = RoomStatusEnum.Cancelled;
        await _repository.UpdateAsync(room);
        await _repository.SaveChanges();
        await _hubContext.Clients.Group(room.RoomId.ToString()).GameEnded(room.RoomId, reason);
    }
}