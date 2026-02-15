using MediatR;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Hubs;
using Microsoft.AspNetCore.SignalR;


namespace Bingo.Core.Features.Gameplay.Handler;

public class ClaimWinCommandHandler : IRequestHandler<ClaimWinCommand, Response<Win>>
{
    private readonly IBingoRepository _repository;
    private readonly IHubContext<BingoHub> _hubContext;

    public ClaimWinCommandHandler(IBingoRepository repository, IHubContext<BingoHub> hubContext)
    {
        _repository = repository;
        _hubContext = hubContext;
    }

    public async Task<Response<Win>> Handle(ClaimWinCommand request, CancellationToken cancellationToken)
    {
         var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
         if (room == null) return Response<Win>.NotFound("Room not found");
         if (room.Status != RoomStatusEnum.InProgress) return Response<Win>.Error("Game is not active");

         var card = await _repository.FindOneAsync<Card>(c => c.CardId == request.CardId && c.UserId == request.UserId);
         if (card == null) return Response<Win>.NotFound("Card not found");

        bool isWin = false;
        // Verify win against the REQUESTED pattern. 
        // NOTE: We should probably ensure the requested pattern matches the ROOM's pattern pattern.
        if (room.Pattern != (WinPatternEnum)request.WinType && request.WinType != WinTypeEnum.FalseClaim)
        {
             // For now, if patterns don't match, fail.
             return Response<Win>.Error("Invalid Win Type for this Room");
        }

        if (Enum.TryParse<WinPatternEnum>(request.WinType.ToString(), out var pattern))
        {
             isWin = await _repository.VerifyWinAsync(request.CardId, pattern);
        }

        decimal prize = 0;
        if (isWin)
        {
            // Calculate Prize (Copied from ClaimBingo logic: Price * Players * 0.87)
             var playerCount = await _repository.CountAsync<RoomPlayer>(rp => rp.RoomId == request.RoomId);
             prize = room.CardPrice * playerCount * 0.87m;
             
             // Update User Balance
             var user = await _repository.GetUserWithDetailsAsync(request.UserId);
             if (user != null)
             {
                 user.Balance += prize;
                 await _repository.UpdateAsync(user);
             }

             // End Game
             room.Status = RoomStatusEnum.Completed;
             room.EndedAt = DateTime.UtcNow;
             await _repository.UpdateAsync(room);
        }

        var win = new Win
        {
            RoomId = request.RoomId,
            CardId = request.CardId,
            UserId = request.UserId,
            ClaimedAt = DateTime.UtcNow,
            WinType = isWin ? request.WinType : WinTypeEnum.FalseClaim,
            Verified = isWin, 
            VerifiedAt = DateTime.UtcNow,
            Prize = prize 
        };

        await _repository.RecordWinAsync(win);

        if (isWin)
        {
             var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);
             string winnerName = user?.Username ?? "Unknown";
             
             // Get the winning card with its numbers for display
             var winningCard = await _repository.FindOneAsync<Card>(c => c.CardId == request.CardId, 
                 includeProps: new[] { "MasterCard", "MasterCard.Numbers" });
             
             // Prepare card data for frontend
             var cardNumbers = winningCard?.MasterCard?.Numbers?
                 .OrderBy(n => n.PositionRow)
                 .ThenBy(n => n.PositionCol)
                 .Select(n => new
                 {
                     positionRow = n.PositionRow,
                     positionCol = n.PositionCol,
                     number = n.Number
                 })
                 .ToList();
             
             await _hubContext.Clients.Group(request.RoomId.ToString())
                .SendAsync("GameEnded", request.RoomId, $"Winner: {winnerName} Prize: {prize}");
                
             await _hubContext.Clients.Group(request.RoomId.ToString())
                .SendAsync("WinClaimed", request.RoomId, winnerName, request.WinType.ToString(), prize, cardNumbers);
        }

        return Response<Win>.Success(win);
    }
}
