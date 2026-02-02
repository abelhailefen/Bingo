using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.PaymentService.Contract.Command;
using MediatR;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.Collections.Concurrent;
using Telegram.Bot;
using Telegram.Bot.Polling;
using Telegram.Bot.Types;
using Telegram.Bot.Types.Enums;
using Telegram.Bot.Types.ReplyMarkups;

// ALIASES
using BingoUser = Bingo.Core.Entities.User;

namespace Bingo.Core.Services;

public class TelegramBotService : BackgroundService
{
    private readonly IConfiguration _config;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ITelegramBotClient _botClient;
    private readonly string _adminGroupId;

    // In-memory state tracker: Maps ChatId to status
    private static readonly ConcurrentDictionary<long, PaymentProviderEnum> _pendingDeposits = new();
    private static readonly ConcurrentDictionary<long, bool> _pendingWithdrawals = new();

    public TelegramBotService(IConfiguration config, IServiceScopeFactory scopeFactory, ITelegramBotClient botClient)
    {
        _config = config;
        _scopeFactory = scopeFactory;
        _botClient = botClient;
        _adminGroupId = _config["TelegramBot:AdminGroupId"] ?? "";
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var receiverOptions = new ReceiverOptions
        {
            AllowedUpdates = [UpdateType.Message, UpdateType.CallbackQuery]
        };

        _botClient.StartReceiving(
            updateHandler: HandleUpdateAsync,
            errorHandler: HandlePollingErrorAsync,
            receiverOptions: receiverOptions,
            cancellationToken: stoppingToken
        );

        Console.WriteLine("Telegram Bot is running with Admin Approval Support...");
        return Task.CompletedTask;
    }

    private async Task HandleUpdateAsync(ITelegramBotClient botClient, Update update, CancellationToken ct)
    {
        // 1. Handle Button Clicks (Callback Queries)
        if (update.CallbackQuery is { } callbackQuery)
        {
            await HandleCallbackQuery(botClient, callbackQuery, ct);
            return;
        }

        // 2. Handle Contact Sharing (Registration)
        if (update.Message is { Type: MessageType.Contact, Contact: { } contact })
        {
            await HandleContactUpdate(botClient, update.Message, contact, ct);
            return;
        }

        // 3. Handle Text Messages
        if (update.Message is not { Text: { } messageText } message) return;
        var chatId = message.Chat.Id;

        // Check if user is currently pasting a deposit receipt
        if (_pendingDeposits.TryRemove(chatId, out var provider))
        {
            await ProcessReceipt(botClient, message, provider, ct);
            return;
        }

        // Check if user is entering a withdrawal amount
        if (_pendingWithdrawals.TryRemove(chatId, out _))
        {
            await ProcessWithdrawal(botClient, message, ct);
            return;
        }

        var command = messageText.Split(' ')[0].ToLower();
        switch (command)
        {
            case "/start":
                await HandleStartCommand(botClient, message, ct);
                break;
            case "/admin_users": // <--- Add this case
                if (chatId.ToString() == _adminGroupId)
                {
                    await HandleListAllUsers(botClient, chatId, ct);
                }
                else
                {
                    await botClient.SendMessage(chatId, "❌ This is an admin-only command.", cancellationToken: ct);
                }
                break;
            case "/help":
                await botClient.SendMessage(chatId, "Use the buttons to Deposit or Withdraw. Share contact to register.", cancellationToken: ct);
                break;
        }
    }
    private async Task HandleListAllUsers(ITelegramBotClient botClient, long chatId, CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();

        // Fetch all users from the DB
        // If your repository has a generic ListAsync, use that. 
        // Otherwise, you might need to add a GetAll method to your repo interface.
        var users = await repo.FindAsync<BingoUser>(u => true);

        if (users == null || !users.Any())
        {
            await botClient.SendMessage(chatId, "📭 No users registered yet.", cancellationToken: ct);
            return;
        }

        var userListText = "👥 **Registered Users List**\n\n";
        foreach (var u in users)
        {
            // Formatting: Username (Balance) - Phone
            userListText += $"• {u.Username} | 💰 {u.Balance} ETB | `{u.PhoneNumber}`\n";

            // Telegram messages have a 4096 character limit. 
            // If you have hundreds of users, you might need to split the message.
            if (userListText.Length > 3500)
            {
                await botClient.SendMessage(chatId, userListText, parseMode: ParseMode.Markdown, cancellationToken: ct);
                userListText = "";
            }
        }

        if (!string.IsNullOrEmpty(userListText))
        {
            await botClient.SendMessage(chatId, userListText, parseMode: ParseMode.Markdown, cancellationToken: ct);
        }
    }
    private async Task HandleCallbackQuery(ITelegramBotClient botClient, CallbackQuery query, CancellationToken ct)
    {
        var chatId = query.Message!.Chat.Id;
        var data = query.Data ?? "";

        // --- SECTION A: ADMIN ACTIONS ---
        if (data.StartsWith("adm_wd_"))
        {
            if (chatId.ToString() != _adminGroupId)
            {
                await botClient.AnswerCallbackQuery(query.Id, "Unauthorized.", cancellationToken: ct);
                return;
            }
            await HandleAdminApprovalAction(botClient, query, ct);
            return;
        }

        // --- SECTION B: USER ACTIONS ---
        if (data == "start_deposit")
        {
            var keyboard = new InlineKeyboardMarkup(new[] {
            new[] { InlineKeyboardButton.WithCallbackData("Telebirr", "pay_telebirr") },
            new[] { InlineKeyboardButton.WithCallbackData("CBE (Commercial Bank)", "pay_cbe") }
        });
            await botClient.SendMessage(chatId, "Select your payment provider:", replyMarkup: keyboard, cancellationToken: ct);
        }
        else if (data == "pay_telebirr")
        {
            _pendingDeposits[chatId] = PaymentProviderEnum.Telebirr;

            // Updated with Telebirr account info
            string message = "<b>Telebirr Payment Details:</b>\n\n" +
                             "Name: <b>Rediet Endale Belay</b>\n" +
                             "Phone: <code>+251913588491</code>\n\n" +
                             "Please complete the transfer and then paste the Telebirr SMS or Receipt URL below:";

            await botClient.SendMessage(
                chatId: chatId,
                text: message,
                parseMode: Telegram.Bot.Types.Enums.ParseMode.Html,
                cancellationToken: ct);
        }
        else if (data == "pay_cbe")
        {
            _pendingDeposits[chatId] = PaymentProviderEnum.CBE;

            // Updated with CBE account info
            string message = "<b>CBE Payment Details:</b>\n\n" +
                             "Account Number: <code>1000459382171</code>\n" +
                             "Name: <b>NAHOM SHIMELIS TESHOME</b>\n\n" +
                             "Please complete the transfer and then paste the CBE Receipt URL/Text below:";

            await botClient.SendMessage(
                chatId: chatId,
                text: message,
                parseMode: Telegram.Bot.Types.Enums.ParseMode.Html,
                cancellationToken: ct);
        }
        else if (data == "start_withdrawal")
        {
            using var scope = _scopeFactory.CreateScope();
            var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
            var user = await repo.FindOneAsync<BingoUser>(u => u.UserId == query.From.Id);

            if (user == null)
            {
                await botClient.SendMessage(chatId, "User not found. Please /start again.", cancellationToken: ct);
            }
            else
            {
                _pendingWithdrawals[chatId] = true;
                await botClient.SendMessage(chatId, $"Your balance: {user.Balance} ETB.\nEnter amount to withdraw (numbers only):", cancellationToken: ct);
            }
        }

        await botClient.AnswerCallbackQuery(query.Id, cancellationToken: ct);
    }
    private async Task HandleAdminApprovalAction(ITelegramBotClient botClient, CallbackQuery query, CancellationToken ct)
    {
        var parts = query.Data!.Split('_'); // adm, wd, [appr/rej], [id]
        var action = parts[2];
        var requestId = int.Parse(parts[3]);

        using var scope = _scopeFactory.CreateScope();
        var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();
        var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();

        var newStatus = action == "appr" ? WithdrawalStatusEnum.Approved : WithdrawalStatusEnum.Rejected;

        // 1. Update DB using the Mediator Command
        var result = await mediator.Send(new UpdateWithdrawalStatusCommand(requestId, newStatus, $"Handled by @{query.From.Username}"), ct);

        if (result.Data)
        {
            // 2. Update the message in Admin Group to show it's done
            await botClient.EditMessageText(
                query.Message!.Chat.Id,
                query.Message.MessageId,
                query.Message.Text + $"\n\n✅ Request {newStatus} by @{query.From.Username}",
                replyMarkup: null,
                parseMode: ParseMode.Markdown,
                cancellationToken: ct);

            // 3. Find user and notify them
            var wdRequest = await repo.FindOneAsync<WithdrawalRequest>(w => w.WithdrawalRequestId == requestId);
            if (wdRequest != null)
            {
                string userMsg = newStatus == WithdrawalStatusEnum.Approved
                    ? $"✅ Your withdrawal of {wdRequest.Amount} ETB has been approved!"
                    : $"❌ Your withdrawal of {wdRequest.Amount} ETB was rejected. Funds returned to balance.";

                await botClient.SendMessage(wdRequest.UserId, userMsg, cancellationToken: ct);
            }
        }

        await botClient.AnswerCallbackQuery(query.Id, result.Message, cancellationToken: ct);
    }

    private async Task ProcessReceipt(ITelegramBotClient botClient, Message message, PaymentProviderEnum provider, CancellationToken ct)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();
            await botClient.SendMessage(message.Chat.Id, "⏳ Validating payment...", cancellationToken: ct);

            var result = await mediator.Send(new ProcessPaymentCommand(message.From!.Id, message.Text!, provider), ct);

            if (result != null && !result.IsFailed)
                await botClient.SendMessage(message.Chat.Id, $"✅ Success! {result.Message}", cancellationToken: ct);
            else
                await botClient.SendMessage(message.Chat.Id, $"❌ Failed: {result?.Message}", cancellationToken: ct);
        }
        catch (Exception ex) { await botClient.SendMessage(message.Chat.Id, $"❌ Error: {ex.Message}", cancellationToken: ct); }
    }

    private async Task ProcessWithdrawal(ITelegramBotClient botClient, Message message, CancellationToken ct)
    {
        try
        {
            if (!decimal.TryParse(message.Text, out var amount))
            {
                await botClient.SendMessage(message.Chat.Id, "❌ Invalid amount. Numbers only.", cancellationToken: ct);
                return;
            }

            using var scope = _scopeFactory.CreateScope();
            var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();
            await botClient.SendMessage(message.Chat.Id, "⏳ Submitting request...", cancellationToken: ct);

            var result = await mediator.Send(new CreateWithdrawalRequestCommand(message.From!.Id, amount), ct);

            if (result != null && !result.IsFailed)
                await botClient.SendMessage(message.Chat.Id, $"✅ Submitted! {result.Message}", cancellationToken: ct);
            else
                await botClient.SendMessage(message.Chat.Id, $"❌ Failed: {result?.Message}", cancellationToken: ct);
        }
        catch (Exception ex) { await botClient.SendMessage(message.Chat.Id, $"❌ Error: {ex.Message}", cancellationToken: ct); }
    }

    private async Task HandleStartCommand(ITelegramBotClient botClient, Message message, CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
        var user = await repo.FindOneAsync<BingoUser>(u => u.UserId == message.From!.Id);

        if (user == null || string.IsNullOrEmpty(user.PhoneNumber))
        {
            var contactButton = new ReplyKeyboardMarkup(new[] { KeyboardButton.WithRequestContact("📲 Register & Share Contact") }) { ResizeKeyboard = true, OneTimeKeyboard = true };
            await botClient.SendMessage(message.Chat.Id, "Welcome! Share contact to create your account.", replyMarkup: contactButton, cancellationToken: ct);
        }
        else
        {
            await SetupAndShowWebApp(botClient, message.Chat.Id, $"Welcome back! Balance: {user.Balance} ETB.", ct);
        }
    }

    private async Task SetupAndShowWebApp(ITelegramBotClient botClient, long chatId, string messageText, CancellationToken ct)
    {
        var webAppUrl = _config["TelegramBot:WebAppUrl"]!;
        await botClient.SetChatMenuButton(chatId, new MenuButtonWebApp { Text = "Play Bingo", WebApp = new WebAppInfo { Url = webAppUrl } }, ct);

        var inlineKeyboard = new InlineKeyboardMarkup(new[] {
            new [] { InlineKeyboardButton.WithWebApp("🎮 Open Bingo Game", new WebAppInfo { Url = webAppUrl }) },
            new [] { InlineKeyboardButton.WithCallbackData("💰 Deposit", "start_deposit"), InlineKeyboardButton.WithCallbackData("💸 Withdraw", "start_withdrawal") }
        });

        await botClient.SendMessage(chatId, messageText, replyMarkup: inlineKeyboard, cancellationToken: ct);
    }

    private async Task HandleContactUpdate(ITelegramBotClient botClient, Message message, Contact contact, CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
        var user = await repo.FindOneAsync<BingoUser>(u => u.UserId == contact.UserId);

        if (user == null)
        {
            user = new BingoUser { UserId = contact.UserId!.Value, Username = message.From!.Username ?? $"User_{contact.UserId}", PhoneNumber = contact.PhoneNumber, PasswordHash = "tg_auth", Balance = 0 };
            await repo.AddAsync(user);
        }
        else
        {
            user.PhoneNumber = contact.PhoneNumber;
            await repo.UpdateAsync(user);
        }

        await repo.SaveChanges();
        await botClient.SendMessage(message.Chat.Id, "✅ Registered!", replyMarkup: new ReplyKeyboardRemove(), cancellationToken: ct);
        await SetupAndShowWebApp(botClient, message.Chat.Id, "Ready to play?", ct);
    }

    private Task HandlePollingErrorAsync(ITelegramBotClient botClient, Exception exception, CancellationToken ct)
    {
        Console.WriteLine($"Telegram Error: {exception.Message}");
        return Task.CompletedTask;
    }
}