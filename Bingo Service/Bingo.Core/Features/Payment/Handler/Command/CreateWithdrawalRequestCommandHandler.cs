using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.PaymentService.Contract.Command;
using Bingo.Core.Models;
using MediatR;
using Microsoft.Extensions.Configuration;
using Telegram.Bot; // Add this
using Telegram.Bot.Types.Enums; // Add this
using Telegram.Bot.Types.ReplyMarkups; // Add this
namespace Bingo.Core.Features.PaymentService.Handler.Command;

public class CreateWithdrawalRequestCommandHandler : IRequestHandler<CreateWithdrawalRequestCommand, Response<bool>>
{
    private readonly IBingoRepository _repository;
    private readonly ITelegramBotClient _botClient; // Add this
    private readonly string _adminGroupId;
    public CreateWithdrawalRequestCommandHandler(IBingoRepository repository, ITelegramBotClient botClient, IConfiguration config)
    {
        _repository = repository;
        _botClient = botClient;
        _adminGroupId = config["TelegramBot:AdminGroupId"]!;

    }

    public async Task<Response<bool>> Handle(CreateWithdrawalRequestCommand request, CancellationToken ct)
    {
        try
        {
            if (request.Amount <= 0)
                return Response<bool>.Error("Amount must be greater than zero.");

            var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);
            if (user == null)
                return Response<bool>.Error("User not found.");

            if (user.Balance < request.Amount)
                return Response<bool>.Error($"Insufficient balance. Your balance is {user.Balance} ETB.");

            // Deduct balance immediately
            user.Balance -= request.Amount;
            user.UpdatedAt = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Utc);

            var withdrawalRequest = new WithdrawalRequest
            {
                UserId = request.UserId,
                Amount = request.Amount,
                Status = WithdrawalStatusEnum.Pending,
                CreatedAt = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Utc)
            };

            await _repository.AddAsync(withdrawalRequest);
            await _repository.UpdateAsync(user);
            await _repository.SaveChanges();

            // 2. NOTIFY ADMIN GROUP
            var keyboard = new InlineKeyboardMarkup(new[]
            {
                new[]
                {
                    InlineKeyboardButton.WithCallbackData("✅ Approve", $"adm_wd_appr_{withdrawalRequest.WithdrawalRequestId}"),
                    InlineKeyboardButton.WithCallbackData("❌ Reject", $"adm_wd_rej_{withdrawalRequest.WithdrawalRequestId}")
                }
            });

            string adminMsg = $"🚨 **New Withdrawal Request**\n\n" +
                              $"👤 User: {user.Username}\n" +
                              $"📞 Phone: `{user.PhoneNumber}`\n" +
                              $"💰 Amount: {request.Amount} ETB\n" +
                              $"💳 User Balance: {user.Balance} ETB\n" + 
                              $"🆔 ID: {withdrawalRequest.WithdrawalRequestId}";

            await _botClient.SendMessage(_adminGroupId, adminMsg,
                parseMode: ParseMode.Markdown,
                replyMarkup: keyboard,
                cancellationToken: ct);

          
            Response<bool> response = new Response<bool>();
            response.Data = true;
            response.Message = "Withdrawal request created successfully.";
            return response;
        }
        catch (Exception ex)
        {
            return Response<bool>.Error($"Error creating withdrawal request: {ex.Message}");
        }
    }
}
