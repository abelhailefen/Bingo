using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.PaymentService.Contract.Command;
using Bingo.Core.Features.PaymentService.Contract.Service;
using Bingo.Core.Models;
using MediatR;

namespace Bingo.Core.Features.PaymentService.Handler.Command;

public class ProcessPaymentCommandHandler : IRequestHandler<ProcessPaymentCommand, Response<bool>>
{
    private readonly IBingoRepository _repository;
    private readonly IPaymentService _paymentService;

    // TELEBIRR Verification Details
    private const string TELEBIRR_TARGET_NAME = "Eyosias Hailemariam Fentaw";
    private const string TELEBIRR_TARGET_LAST4 = "4371";

    // CBE Verification Details 
    // (Update these if they differ from Telebirr)
    private const string CBE_TARGET_NAME = "Eyosias Hailemariam Fentaw";
    private const string CBE_TARGET_LAST4 = "4371";

    public ProcessPaymentCommandHandler(IBingoRepository repository, IPaymentService paymentService)
    {
        _repository = repository;
        _paymentService = paymentService;
    }

    public async Task<Response<bool>> Handle(ProcessPaymentCommand request, CancellationToken ct)
    {
        try
        {
            decimal amountProcessed = 0;
            string transactionRef = string.Empty;

            /* 1. VALIDATION PHASE */
            if (request.Provider == PaymentProviderEnum.Telebirr)
            {
                var receipt = await _paymentService.ValidateTeleBirrPayment(request.SmsText);

                if (receipt == null)
                    return Response<bool>.Error("Could not validate Telebirr receipt. Ensure the link is valid.");

                // Verify Receiver Identity
                if (!receipt.CreditedPartyName.Equals(TELEBIRR_TARGET_NAME, StringComparison.OrdinalIgnoreCase) ||
                    receipt.CreditedPartyAccountLast4 != TELEBIRR_TARGET_LAST4)
                {
                    return Response<bool>.Error($"Security Check Failed: Payment was sent to {receipt.CreditedPartyName} (...{receipt.CreditedPartyAccountLast4}) instead of the official account.");
                }

                amountProcessed = receipt.AmountEtb;
                transactionRef = receipt.TransactionId;
            }
            else if (request.Provider == PaymentProviderEnum.CBE)
            {
                var receipt = await _paymentService.ValidateTCBEPayment(request.SmsText);

                if (receipt == null)
                    return Response<bool>.Error("Could not validate CBE receipt. Ensure the link is valid.");

                // Verify Receiver Identity
                if (!receipt.ReceiverName.Equals(CBE_TARGET_NAME, StringComparison.OrdinalIgnoreCase) ||
                    receipt.ReceiverAccountLast4 != CBE_TARGET_LAST4)
                {
                    return Response<bool>.Error($"Security Check Failed: Payment was sent to {receipt.ReceiverName} (...{receipt.ReceiverAccountLast4}) instead of the official account.");
                }

                amountProcessed = receipt.AmountEtb;
                transactionRef = receipt.ReferenceNumber;
            }
            else
            {
                return Response<bool>.Error("Unsupported payment provider selected.");
            }

            /* 2. DUPLICATE CHECK (Anti-Fraud) */
            var alreadyExists = await _repository.AnyAsync<Payment>(p => p.TransactionReference == transactionRef);
            if (alreadyExists)
            {
                return Response<bool>.Error("This transaction has already been processed and added to a balance.");
            }

            /* 3. DATABASE UPDATE PHASE */
            // Using a generic find or specific one from your repository
            var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);
            if (user == null)
                return Response<bool>.Error("User account not found in database.");

            // Create Payment Log
            var paymentLog = new Payment
            {
                UserId = request.UserId,
                TransactionReference = transactionRef,
                Amount = amountProcessed,
                Provider = request.Provider,
                CreatedAt = DateTime.UtcNow
            };

            // Update User Balance
            user.Balance += amountProcessed;
            user.UpdatedAt = DateTime.UtcNow;

            // Persist Changes
            await _repository.AddAsync(paymentLog);
            await _repository.UpdateAsync(user);
            await _repository.SaveChanges();

            var result = Response<bool>.Success(true);
            result.Message = $"Payment of {amountProcessed} ETB processed successfully.";
            return result;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"PAYMENT_ERROR: {ex.Message}");
            Console.WriteLine($"STACK_TRACE: {ex.StackTrace}"); // Look at your console log for this!
            return Response<bool>.Error($"Processing error: {ex.Message}");
        }
    }
}