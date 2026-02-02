using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.PaymentService.Contract.Command;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.PaymentService.Handler.Command;

public class UpdateWithdrawalStatusCommandHandler : IRequestHandler<UpdateWithdrawalStatusCommand, Response<bool>>
{
    private readonly IBingoRepository _repository;

    public UpdateWithdrawalStatusCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<bool>> Handle(UpdateWithdrawalStatusCommand request, CancellationToken ct)
    {
        try
        {
            var withdrawal = await _repository.FindOneAsync<WithdrawalRequest>(w => w.WithdrawalRequestId == request.WithdrawalRequestId);
            
            if (withdrawal == null)
                return Response<bool>.Error("Withdrawal request not found.");

            if (withdrawal.Status != WithdrawalStatusEnum.Pending)
                return Response<bool>.Error($"Request is already {withdrawal.Status}. Cannot update status.");

            if (request.NewStatus == WithdrawalStatusEnum.Pending)
                return Response<bool>.Error("Cannot update status back to Pending.");

            withdrawal.Status = request.NewStatus;
            withdrawal.AdminComment = request.AdminComment;
            withdrawal.ProcessedAt = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Utc);

            // If Rejected, refund the amount
            if (request.NewStatus == WithdrawalStatusEnum.Rejected)
            {
                var user = await _repository.FindOneAsync<User>(u => u.UserId == withdrawal.UserId);
                if (user != null)
                {
                    user.Balance += withdrawal.Amount;
                    await _repository.UpdateAsync(user);
                }
            }

            await _repository.UpdateAsync(withdrawal);
            await _repository.SaveChanges();
            
            Response<bool> result = new Response<bool>();
            result.Data = true;
            result.Message = $"Withdrawal request {request.NewStatus}.";
            return result;
        }
        catch (Exception ex)
        {
            return Response<bool>.Error($"Error updating withdrawal status: {ex.Message}");
        }
    }
}
