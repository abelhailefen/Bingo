using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.PaymentService.Contract.Command;

public record CreateWithdrawalRequestCommand(
    long UserId,
    decimal Amount
) : IRequest<Response<bool>>;
