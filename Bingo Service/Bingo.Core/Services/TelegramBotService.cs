using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities.Enums;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Telegram.Bot;
using Telegram.Bot.Polling;
using Telegram.Bot.Types;
using Telegram.Bot.Types.Enums;
using Telegram.Bot.Types.ReplyMarkups;

// ALIASES to fix the "User" ambiguity conflict
using BingoUser = Bingo.Core.Entities.User;
using BingoRoom = Bingo.Core.Entities.Room;

namespace Bingo.Core.Services;

public class TelegramBotService : BackgroundService
{
    private readonly IConfiguration _config;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ITelegramBotClient _botClient;

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

        Console.WriteLine("Telegram Bot is running with Trusted Menu Button support...");
        return Task.CompletedTask;
    }

    private async Task HandleUpdateAsync(ITelegramBotClient botClient, Update update, CancellationToken ct)
    {
        // 1. Handle Contact Sharing (Physical Phone Number Registration)
        if (update.Message is { Type: MessageType.Contact, Contact: { } contact })
        {
            await HandleContactUpdate(botClient, update.Message, contact, ct);
            return;
        }

        // 2. Handle Text Commands
        if (update.Message is not { Text: { } messageText } message) return;
        var chatId = message.Chat.Id;
        var command = messageText.Split(' ')[0].ToLower();

        switch (command)
        {
            case "/start":
                await HandleStartCommand(botClient, message, ct);
                break;

            case "/help":
                await botClient.SendMessage(chatId, "Please share your contact to register, then use the 'Play Bingo' button.", cancellationToken: ct);
                break;
        }
    }

    private async Task HandleStartCommand(ITelegramBotClient botClient, Message message, CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IBingoRepository>();

        // Check if user already exists in DB
        var user = await repo.FindOneAsync<BingoUser>(u => u.UserId == message.From!.Id);

        // If user is missing or has no phone number, trigger registration flow
        if (user == null || string.IsNullOrEmpty(user.PhoneNumber) || user.PhoneNumber == "N/A")
        {
            var contactButton = new ReplyKeyboardMarkup(new[]
            {
                KeyboardButton.WithRequestContact("📲 Register & Share Contact")
            })
            {
                ResizeKeyboard = true,
                OneTimeKeyboard = true
            };

            await botClient.SendMessage(
                chatId: message.Chat.Id,
                text: "Welcome to Bingo! To ensure a secure experience, please share your contact to create your account.",
                replyMarkup: contactButton,
                cancellationToken: ct
            );
        }
        else
        {
            // Already registered? Setup and Show WebApp access
            await SetupAndShowWebApp(botClient, message.Chat.Id, $"Welcome back, {user.Username}!", ct);
        }
    }

    private async Task HandleContactUpdate(ITelegramBotClient botClient, Message message, Contact contact, CancellationToken ct)
    {
        // Security: Ensure the shared contact belongs to the person who sent the message
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

        // Registration done: Clean up the contact keyboard
        await botClient.SendMessage(
            chatId: message.Chat.Id,
            text: "✅ Registration complete! You can now start playing.",
            replyMarkup: new ReplyKeyboardRemove(),
            cancellationToken: ct
        );

        // Configure the Menu Button and provide the link
        await SetupAndShowWebApp(botClient, message.Chat.Id, "Ready to start your first game?", ct);
    }

    private async Task SetupAndShowWebApp(ITelegramBotClient botClient, long chatId, string messageText, CancellationToken ct)
    {
        var webAppUrl = _config["TelegramBot:WebAppUrl"] ?? "http://localhost:7051";

        // 1. SET THE MENU BUTTON (The button next to the text input)
        // This makes the WebApp "Official" for the user and reduces warnings
        await botClient.SetChatMenuButton(
            chatId: chatId,
            menuButton: new MenuButtonWebApp
            {
                Text = "Play Bingo",
                WebApp = new WebAppInfo { Url = webAppUrl }
            },
            cancellationToken: ct
        );

        // 2. Send an Inline Keyboard button as well
        var inlineKeyboard = new InlineKeyboardMarkup(new[]
        {
            new [] { InlineKeyboardButton.WithWebApp("🎮 Open Bingo Game", new WebAppInfo { Url = webAppUrl }) }
        });

        await botClient.SendMessage(
            chatId: chatId,
            text: messageText,
            replyMarkup: inlineKeyboard,
            cancellationToken: ct
        );
    }

    private Task HandlePollingErrorAsync(ITelegramBotClient botClient, Exception exception, CancellationToken ct)
    {
        var errorMessage = exception.Message;
        Console.WriteLine($"Telegram Error: {errorMessage}");
        return Task.CompletedTask;
    }
}