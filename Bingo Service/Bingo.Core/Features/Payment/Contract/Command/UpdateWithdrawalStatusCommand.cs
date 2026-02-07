using Bingo.Core.Entities.Enums;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.PaymentService.Contract.Command;

public record UpdateWithdrawalStatusCommand(
    long WithdrawalRequestId,
    WithdrawalStatusEnum NewStatus,
    string? AdminComment = null
) : IRequest<Response<bool>>;
