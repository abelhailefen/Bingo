using Bingo.Core.Contract.Repository;
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

    // In-memory state tracker: Maps ChatId to selected PaymentProvider
    private static readonly ConcurrentDictionary<long, PaymentProviderEnum> _pendingDeposits = new();

    public TelegramBotService(IConfiguration config, IServiceScopeFactory scopeFactory)
    {
        _config = config;
        _scopeFactory = scopeFactory;
        _botClient = new TelegramBotClient(_config["TelegramBot:Token"]!);
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

        Console.WriteLine("Telegram Bot is running with Deposit support...");
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

        // 2. Handle Contact Sharing
        if (update.Message is { Type: MessageType.Contact, Contact: { } contact })
        {
            await HandleContactUpdate(botClient, update.Message, contact, ct);
            return;
        }

        // 3. Handle Text Messages
        if (update.Message is not { Text: { } messageText } message) return;
        var chatId = message.Chat.Id;

        // Check if user is currently pasting a receipt
        if (_pendingDeposits.TryRemove(chatId, out var provider))
        {
            await ProcessReceipt(botClient, message, provider, ct);
            return;
        }

        var command = messageText.Split(' ')[0].ToLower();
        switch (command)
        {
            case "/start":
                await HandleStartCommand(botClient, message, ct);
                break;
            case "/help":
                await botClient.SendMessage(chatId, "Share contact to register. Use 'Deposit' to add funds.", cancellationToken: ct);
                break;
        }
    }

    private async Task HandleCallbackQuery(ITelegramBotClient botClient, CallbackQuery query, CancellationToken ct)
    {
        var chatId = query.Message!.Chat.Id;

        if (query.Data == "start_deposit")
        {
            var keyboard = new InlineKeyboardMarkup(new[]
            {
                new[] { InlineKeyboardButton.WithCallbackData("Telebirr", "pay_telebirr") },
                //new[] { InlineKeyboardButton.WithCallbackData("CBE (Commercial Bank)", "pay_cbe") }
            });

            await botClient.SendMessage(chatId, "Select your payment provider:", replyMarkup: keyboard, cancellationToken: ct);
        }
        else if (query.Data == "pay_telebirr")
        {
            _pendingDeposits[chatId] = PaymentProviderEnum.Telebirr;
            await botClient.SendMessage(chatId, "Please paste the Telebirr SMS or Receipt URL below:", cancellationToken: ct);
        }
        else if (query.Data == "pay_cbe")
        {
            _pendingDeposits[chatId] = PaymentProviderEnum.CBE;
            await botClient.SendMessage(chatId, "Please paste the CBE Receipt URL/Text below:", cancellationToken: ct);
        }

        // Acknowledge the callback
        await botClient.AnswerCallbackQuery(query.Id, cancellationToken: ct);
    }

    private async Task ProcessReceipt(ITelegramBotClient botClient, Message message, PaymentProviderEnum provider, CancellationToken ct)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();

            await botClient.SendMessage(message.Chat.Id, "⏳ Validating payment, please wait...", cancellationToken: ct);

            var result = await mediator.Send(new ProcessPaymentCommand(message.From!.Id, message.Text!, provider), ct);

            if (result != null && !result.IsFailed)
            {
                await botClient.SendMessage(message.Chat.Id, $"✅ Success! {result.Message}", cancellationToken: ct);
            }
            else
            {
                // CHANGED: Use the actual error message from the result
                var errorMsg = result?.Message ?? "Validation failed. Please ensure the receipt is correct.";
                await botClient.SendMessage(message.Chat.Id, $"❌ Failed: {errorMsg}", cancellationToken: ct);
            }
        }
        catch (Exception ex)
        {
            await botClient.SendMessage(message.Chat.Id, $"❌ System Error: {ex.Message}", cancellationToken: ct);
        }
    }

    private async Task SetupAndShowWebApp(ITelegramBotClient botClient, long chatId, string messageText, CancellationToken ct)
    {
        var webAppUrl = _config["TelegramBot:WebAppUrl"] ?? "https://poems-pumps-archive-pensions.trycloudflare.com";

        await botClient.SetChatMenuButton(chatId, new MenuButtonWebApp
        {
            Text = "Play Bingo",
            WebApp = new WebAppInfo { Url = webAppUrl }
        }, ct);

        var inlineKeyboard = new InlineKeyboardMarkup(new[]
        {
            new [] { InlineKeyboardButton.WithWebApp("🎮 Open Bingo Game", new WebAppInfo { Url = webAppUrl }) },
            new [] { InlineKeyboardButton.WithCallbackData("💰 Deposit Funds", "start_deposit") } // The new Deposit option
        });

        await botClient.SendMessage(chatId, messageText, replyMarkup: inlineKeyboard, cancellationToken: ct);
    }

    // ... Keep existing HandleStartCommand, HandleContactUpdate, HandlePollingErrorAsync ...

    private async Task HandleStartCommand(ITelegramBotClient botClient, Message message, CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
        var user = await repo.FindOneAsync<BingoUser>(u => u.UserId == message.From!.Id);

        if (user == null || string.IsNullOrEmpty(user.PhoneNumber) || user.PhoneNumber == "N/A")
        {
            var contactButton = new ReplyKeyboardMarkup(new[] { KeyboardButton.WithRequestContact("📲 Register & Share Contact") })
            { ResizeKeyboard = true, OneTimeKeyboard = true };

            await botClient.SendMessage(message.Chat.Id, "Welcome! Please share your contact to create your account.", replyMarkup: contactButton, cancellationToken: ct);
        }
        else
        {
            await SetupAndShowWebApp(botClient, message.Chat.Id, $"Welcome back, {user.Username}! Your balance is {user.Balance} ETB.", ct);
        }
    }

    private async Task HandleContactUpdate(ITelegramBotClient botClient, Message message, Contact contact, CancellationToken ct)
    {
        if (message.From?.Id != contact.UserId)
        {
            await botClient.SendMessage(message.Chat.Id, "Please share your OWN contact info.", cancellationToken: ct);
            return;
        }

        using var scope = _scopeFactory.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();
        var user = await repo.FindOneAsync<BingoUser>(u => u.UserId == contact.UserId);

        if (user == null)
        {
            user = new BingoUser
            {
                UserId = contact.UserId!.Value,
                Username = message.From.Username ?? $"User_{contact.UserId}",
                PhoneNumber = contact.PhoneNumber,
                PasswordHash = "telegram_auth_managed",
                Balance = 0,
                CreatedAt = DateTime.UtcNow
            };
            await repo.AddAsync(user);
        }
        else
        {
            user.PhoneNumber = contact.PhoneNumber;
            await repo.UpdateAsync(user);
        }

        await repo.SaveChanges();
        await botClient.SendMessage(message.Chat.Id, "✅ Registration complete!", replyMarkup: new ReplyKeyboardRemove(), cancellationToken: ct);
        await SetupAndShowWebApp(botClient, message.Chat.Id, "Ready to start your first game?", ct);
    }

    private Task HandlePollingErrorAsync(ITelegramBotClient botClient, Exception exception, CancellationToken ct)
    {
        Console.WriteLine($"Telegram Error: {exception.Message}");
        return Task.CompletedTask;
    }
}