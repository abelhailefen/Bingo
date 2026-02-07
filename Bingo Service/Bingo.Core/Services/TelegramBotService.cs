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

    private static readonly ConcurrentDictionary<long, PaymentProviderEnum> _pendingDeposits = new();
    private static readonly ConcurrentDictionary<long, bool> _pendingWithdrawals = new();

    private const string BTN_PLAY = "🎮 Play Bingo";
    private const string BTN_DEPOSIT = "💰 Deposit";
    private const string BTN_WITHDRAW = "💸 Withdraw";

    public TelegramBotService(IConfiguration config, IServiceScopeFactory scopeFactory, ITelegramBotClient botClient)
    {
        _config = config;
        _scopeFactory = scopeFactory;
        _botClient = botClient;
        _adminGroupId = _config["TelegramBot:AdminGroupId"] ?? "";
    }

    private IReplyMarkup GetMenuKeyboard()
    {
        var webAppUrl = _config["TelegramBot:WebAppUrl"]?.Trim();
        var buttons = new List<KeyboardButton[]>();

        // Add Play button back - frontend now handles missing initData gracefully
        if (!string.IsNullOrEmpty(webAppUrl) && Uri.IsWellFormedUriString(webAppUrl, UriKind.Absolute))
            buttons.Add(new[] { KeyboardButton.WithWebApp(BTN_PLAY, new WebAppInfo { Url = webAppUrl }) });

        buttons.Add(new[] { new KeyboardButton(BTN_DEPOSIT), new KeyboardButton(BTN_WITHDRAW) });

        return new ReplyKeyboardMarkup(buttons) { ResizeKeyboard = true, IsPersistent = true };
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _botClient.StartReceiving(
            updateHandler: HandleUpdateAsync,
            errorHandler: HandlePollingErrorAsync,
            receiverOptions: new ReceiverOptions { AllowedUpdates = [UpdateType.Message, UpdateType.CallbackQuery] },
            cancellationToken: stoppingToken
        );
        return Task.CompletedTask;
    }

    private async Task HandleUpdateAsync(ITelegramBotClient botClient, Update update, CancellationToken ct)
    {
        if (update.CallbackQuery is { } callbackQuery) { await HandleCallbackQuery(botClient, callbackQuery, ct); return; }
        if (update.Message is { Type: MessageType.Contact, Contact: { } contact }) { await HandleContactUpdate(botClient, update.Message, contact, ct); return; }
        if (update.Message is not { Text: { } messageText } message) return;

        var chatId = message.Chat.Id;

        if (_pendingDeposits.TryRemove(chatId, out var provider)) { await ProcessReceipt(botClient, message, provider, ct); return; }
        if (_pendingWithdrawals.TryRemove(chatId, out _)) { await ProcessWithdrawal(botClient, message, ct); return; }

        switch (messageText)
        {
            case "/start": await HandleStartCommand(botClient, message, ct); break;
            case BTN_DEPOSIT: await InitiateDeposit(botClient, chatId, ct); break;
            case BTN_WITHDRAW: await InitiateWithdrawal(botClient, message.From!.Id, chatId, ct); break;
            case "/admin_users":
                if (chatId.ToString() == _adminGroupId) await HandleListAllUsers(botClient, chatId, ct);
                break;
        }
    }

    private async Task HandleStartCommand(ITelegramBotClient botClient, Message message, CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
        var user = await repo.FindOneAsync<BingoUser>(u => u.UserId == message.From!.Id);

        if (user == null || string.IsNullOrEmpty(user.PhoneNumber))
        {
            var contactButton = new ReplyKeyboardMarkup(new[] {
            KeyboardButton.WithRequestContact("📲 Register & Share Contact")
        })
            { ResizeKeyboard = true, OneTimeKeyboard = true };

            await botClient.SendMessage(message.Chat.Id, "Welcome! Please register to start playing.", replyMarkup: contactButton, cancellationToken: ct);
        }
        else
        {
            var webAppUrl = _config["TelegramBot:WebAppUrl"]?.Trim();

            // 1. Set the Menu Button (The "Play" button next to the attachment icon)
            // This is the MOST reliable way to open a WebApp with full Auth data.
            if (!string.IsNullOrEmpty(webAppUrl))
            {
                await botClient.SetChatMenuButton(message.Chat.Id, new MenuButtonWebApp
                {
                    Text = "Play",
                    WebApp = new WebAppInfo { Url = webAppUrl }
                }, ct);
            }

            // 2. Consolidate into ONE message with the persistent Keyboard
            // This removes the inline button message that was cluttering the chat
            await botClient.SendMessage(
                message.Chat.Id,
                $"Welcome back! 💰 Balance: {user.Balance} ETB\n\nSelect an option from the menu below:",
                replyMarkup: GetMenuKeyboard(), // This contains your Keyboard "Play Bingo" button
                cancellationToken: ct
            );
        }
    }

    private async Task InitiateWithdrawal(ITelegramBotClient botClient, long userId, long chatId, CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
        var user = await repo.FindOneAsync<BingoUser>(u => u.UserId == userId);

        if (user == null) return;

        _pendingWithdrawals[chatId] = true;
        // REMOVED ForceReplyMarkup to keep your persistent keyboard visible
        await botClient.SendMessage(chatId, $"Current Balance: {user.Balance} ETB\nEnter amount to withdraw (numbers only):", cancellationToken: ct);
    }

    private async Task ProcessWithdrawal(ITelegramBotClient botClient, Message message, CancellationToken ct)
    {
        try
        {
            if (!decimal.TryParse(message.Text, out var amount))
            {
                await botClient.SendMessage(message.Chat.Id, "❌ Invalid amount. Withdrawal cancelled.", replyMarkup: GetMenuKeyboard(), cancellationToken: ct);
                return;
            }

            using var scope = _scopeFactory.CreateScope();
            var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();
            var result = await mediator.Send(new CreateWithdrawalRequestCommand(message.From!.Id, amount), ct);

            string response = (result != null && !result.IsFailed)
                ? $"✅ Submitted! {result.Message}"
                : $"❌ Request failed: {result?.Message}";

            // Always send the menu keyboard back with the result
            await botClient.SendMessage(message.Chat.Id, response, replyMarkup: GetMenuKeyboard(), cancellationToken: ct);
        }
        catch (Exception ex) { await botClient.SendMessage(message.Chat.Id, $"❌ Error: {ex.Message}", replyMarkup: GetMenuKeyboard(), cancellationToken: ct); }
    }

    private async Task ProcessReceipt(ITelegramBotClient botClient, Message message, PaymentProviderEnum provider, CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();
        var result = await mediator.Send(new ProcessPaymentCommand(message.From!.Id, message.Text!, provider), ct);

        string response = (result != null && !result.IsFailed)
            ? $"✅ Success! {result.Message}"
            : $"❌ Failed: {result?.Message}";

        await botClient.SendMessage(message.Chat.Id, response, replyMarkup: GetMenuKeyboard(), cancellationToken: ct);
    }

    private async Task InitiateDeposit(ITelegramBotClient botClient, long chatId, CancellationToken ct)
    {
        var keyboard = new InlineKeyboardMarkup(new[] {
            new[] { InlineKeyboardButton.WithCallbackData("Telebirr", "pay_telebirr") },
            new[] { InlineKeyboardButton.WithCallbackData("CBE (Commercial Bank)", "pay_cbe") }
        });
        await botClient.SendMessage(chatId, "Select your payment provider:", replyMarkup: keyboard, cancellationToken: ct);
    }

    private async Task HandleCallbackQuery(ITelegramBotClient botClient, CallbackQuery query, CancellationToken ct)
    {
        var chatId = query.Message!.Chat.Id;
        if (query.Data!.StartsWith("adm_wd_")) { await HandleAdminApprovalAction(botClient, query, ct); return; }

        if (query.Data == "pay_telebirr")
        {
            _pendingDeposits[chatId] = PaymentProviderEnum.Telebirr;
            await botClient.SendMessage(chatId, "<b>Telebirr:</b> Rediet Endale | +251913588491\nPaste SMS:", ParseMode.Html, cancellationToken: ct);
        }
        else if (query.Data == "pay_cbe")
        {
            _pendingDeposits[chatId] = PaymentProviderEnum.CBE;
            await botClient.SendMessage(chatId, "<b>CBE:</b> 1000459382171 | NAHOM SHIMELIS\nPaste Receipt:", ParseMode.Html, cancellationToken: ct);
        }
        await botClient.AnswerCallbackQuery(query.Id, cancellationToken: ct);
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
        else { user.PhoneNumber = contact.PhoneNumber; await repo.UpdateAsync(user); }

        await repo.SaveChanges();
        await botClient.SendMessage(message.Chat.Id, "✅ Registered!", replyMarkup: GetMenuKeyboard(), cancellationToken: ct);
    }

    private async Task HandleAdminApprovalAction(ITelegramBotClient botClient, CallbackQuery query, CancellationToken ct)
    {
        var parts = query.Data!.Split('_');
        var action = parts[2];
        var requestId = int.Parse(parts[3]);

        using var scope = _scopeFactory.CreateScope();
        var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();
        var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();

        var newStatus = action == "appr" ? WithdrawalStatusEnum.Approved : WithdrawalStatusEnum.Rejected;
        var result = await mediator.Send(new UpdateWithdrawalStatusCommand(requestId, newStatus, $"Admin @{query.From.Username}"), ct);

        if (result.Data)
        {
            await botClient.EditMessageText(query.Message!.Chat.Id, query.Message.MessageId, query.Message.Text + $"\n\n✅ Request {newStatus}", cancellationToken: ct);
            var req = await repo.FindOneAsync<WithdrawalRequest>(w => w.WithdrawalRequestId == requestId);
            if (req != null) await botClient.SendMessage(req.UserId, $"Withdrawal {newStatus}!", replyMarkup: GetMenuKeyboard(), cancellationToken: ct);
        }
    }

    private async Task HandleListAllUsers(ITelegramBotClient botClient, long chatId, CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
        var users = await repo.FindAsync<BingoUser>(u => true);
        var text = "👥 Users List:\n" + string.Join("\n", users.Select(u => $"• {u.Username} ({u.Balance} ETB)"));
        await botClient.SendMessage(chatId, text, cancellationToken: ct);
    }

    private Task HandlePollingErrorAsync(ITelegramBotClient botClient, Exception ex, CancellationToken ct)
    {
        Console.WriteLine($"Error: {ex.Message}");
        return Task.CompletedTask;
    }
}