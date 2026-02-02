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
    // Update these to your actual official receiving account details
    private const string TELEBIRR_TARGET_NAME = "Rediet Endale Belay";
    private const string TELEBIRR_TARGET_ACC = "2519****8491";
    // CBE Verification Details 
    // (Update these if they differ from Telebirr)
    private const string CBE_TARGET_NAME = "NAHOM SHIMELIS TESHOME";
    private const string CBE_TARGET_LAST4 = "2171";

    public ProcessPaymentCommandHandler(IBingoRepository repository, IPaymentService paymentService)
    {
        _repository = repository;
        _paymentService = paymentService;
    }

    public async Task<Response<bool>> Handle(ProcessPaymentCommand request, CancellationToken ct)
    {
        try
        {
            Console.WriteLine($"Processing payment for provider: {request.Provider}");
            Console.WriteLine($"SMS Text sample: {request.SmsText.Substring(0, Math.Min(100, request.SmsText.Length))}...");

            decimal amountProcessed = 0;
            string transactionRef = string.Empty;

            if (request.Provider == PaymentProviderEnum.Telebirr)
            {
                var receipt = await _paymentService.ValidateTeleBirrPayment(request.SmsText);

                if (receipt == null)
                    return Response<bool>.Error("Could not parse receipt. Please check the link.");

                // VALIDATION
                bool isNameValid = receipt.CreditedPartyName.Equals(TELEBIRR_TARGET_NAME, StringComparison.OrdinalIgnoreCase);
                bool isAccValid = receipt.CreditedPartyAccountLast4.Contains(TELEBIRR_TARGET_ACC);

                if (!isNameValid || !isAccValid)
                {
                    return Response<bool>.Error($"Security Check Failed: Payment sent to {receipt.CreditedPartyName} ({receipt.CreditedPartyAccountLast4})");
                }

                amountProcessed = receipt.AmountEtb;
                transactionRef = receipt.TransactionId; // Will be DAM047X1DM
            }
            else if (request.Provider == PaymentProviderEnum.CBE)
            {
                Console.WriteLine("Validating CBE payment...");
                var receipt = await _paymentService.ValidateTCBEPayment(request.SmsText);

                if (receipt == null)
                {
                    Console.WriteLine("CBE receipt validation failed");
                    return Response<bool>.Error("Could not validate CBE receipt. Ensure the link is valid.");
                }

                Console.WriteLine($"CBE receipt validated: Name={receipt.ReceiverName}, Account=...{receipt.ReceiverAccountLast4}, Amount={receipt.AmountEtb}");

                // Verify Receiver Identity
                if (!receipt.ReceiverName.Equals(CBE_TARGET_NAME, StringComparison.OrdinalIgnoreCase) ||
                    receipt.ReceiverAccountLast4 != CBE_TARGET_LAST4)
                {
                    Console.WriteLine($"Security check failed: Expected {CBE_TARGET_NAME}/...{CBE_TARGET_LAST4}, Got {receipt.ReceiverName}/...{receipt.ReceiverAccountLast4}");
                    return Response<bool>.Error($"Security Check Failed: Payment was sent to {receipt.ReceiverName} (...{receipt.ReceiverAccountLast4}) instead of the official account.");
                }

                amountProcessed = receipt.AmountEtb;
                transactionRef = receipt.ReferenceNumber;
            }
            else
            {
                return Response<bool>.Error("Unsupported payment provider selected.");
            }

            Console.WriteLine($"Transaction reference: {transactionRef}, Amount: {amountProcessed}");

            /* 2. DUPLICATE CHECK (Anti-Fraud) */
            var alreadyExists = await _repository.AnyAsync<Payment>(p => p.TransactionReference == transactionRef);
            if (alreadyExists)
                return Response<bool>.Error("This transaction has already been used.");

            /* DATABASE UPDATE: Increment Balance */
            var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);
            if (user == null) return Response<bool>.Error("User not found.");

            // Create log and add balance
            var paymentLog = new Payment
            {
                UserId = request.UserId,
                TransactionReference = transactionRef,
                Amount = amountProcessed,
                Provider = request.Provider,
                CreatedAt = DateTime.UtcNow
            };

            user.Balance += amountProcessed;

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
            Console.WriteLine($"STACK_TRACE: {ex.StackTrace}");
            return Response<bool>.Error($"Processing error: {ex.Message}");
        }
    }
}