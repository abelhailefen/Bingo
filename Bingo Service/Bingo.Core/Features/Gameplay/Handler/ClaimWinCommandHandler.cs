using MediatR;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities.Enums;


namespace Bingo.Core.Features.Gameplay.Handler;

public class ClaimWinCommandHandler : IRequestHandler<ClaimWinCommand, Response<Win>>
{
    private readonly IBingoRepository _repository;

    public ClaimWinCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<Win>> Handle(ClaimWinCommand request, CancellationToken cancellationToken)
    {
         // Verify existence logic...
         var room = await _repository.FindOneAsync<Room>(r => r.RoomId == request.RoomId);
         if (room == null) return Response<Win>.NotFound("Room not found");
         
         var card = await _repository.FindOneAsync<Card>(c => c.CardId == request.CardId && c.UserId == request.UserId);
         if (card == null) return Response<Win>.NotFound("Card not found");

        
        // Use Repository Verification Logic
        bool isWin = false;
        if (Enum.TryParse<WinPatternEnum>(request.WinType.ToString(), out var pattern))
        {
             isWin = await _repository.VerifyWinAsync(request.CardId, pattern);
        }
        else
        {
             // If WinType is FalseClaim or otherwise not a pattern, it's not a win verification request per se, or is invalid for verification.
             isWin = false;
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
            Prize = isWin ? 100 : 0 
        };

        await _repository.RecordWinAsync(win);

        return Response<Win>.Success(win);
    }
}
