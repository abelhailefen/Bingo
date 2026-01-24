using Bingo.Core.Entities.Enums;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.PaymentService.Contract.Command;

public record ProcessPaymentCommand(
    long UserId,
    string SmsText,
    PaymentProviderEnum Provider
) : IRequest<Response<bool>>;