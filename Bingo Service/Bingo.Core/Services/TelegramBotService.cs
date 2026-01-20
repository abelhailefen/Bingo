using Bingo.Core.Entities.Enums; 

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Telegram.Bot;
using Telegram.Bot.Polling;
using Telegram.Bot.Types;
using Telegram.Bot.Types.Enums;
using Telegram.Bot.Types.ReplyMarkups;
using BingoRoom = Bingo.Core.Entities.Room;
using BingoUser = Bingo.Core.Entities.User;

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
            AllowedUpdates = [] // New C# syntax for empty array
        };

        _botClient.StartReceiving(
            updateHandler: HandleUpdateAsync,
            errorHandler: HandlePollingErrorAsync,
            receiverOptions: receiverOptions,
            cancellationToken: stoppingToken
        );

        Console.WriteLine("Telegram Bot is running...");
        return Task.CompletedTask;
    }

    private async Task HandleUpdateAsync(ITelegramBotClient botClient, Update update, CancellationToken ct)
    {
        if (update.Message is not { Text: { } messageText } message) return;
        var chatId = message.Chat.Id;
        var command = messageText.Split(' ')[0].ToLower();

        // 1. Move the DB scope INSIDE the switch or after the /start check
        // This allows /start to work even if the DB is having issues

        switch (command)
        {
            case "/start":
                var webAppUrl = _config["TelegramBot:WebAppUrl"] ?? "http://localhost:7051";

                var inlineKeyboard = new InlineKeyboardMarkup(new[]
                {
                new [] { InlineKeyboardButton.WithWebApp("Open Bingo Game", new WebAppInfo { Url = webAppUrl }) }
            });

                await botClient.SendMessage(
                    chatId: chatId,
                    text: "Welcome to Bingo! Click the button below:",
                    replyMarkup: inlineKeyboard,
                    cancellationToken: ct
                );
                break;

            case "/newroom":
                using (var scope = _scopeFactory.CreateScope())
                {
                }
                break;

            case "/join":
                var code = messageText.Split(' ').Length > 1 ? messageText.Split(' ')[1] : "";
                using (var scope = _scopeFactory.CreateScope())
                {
                }
                break;
        }
    }

    
   

    // THIS METHOD MUST BE INSIDE THE CLASS BRACES
    private Task HandlePollingErrorAsync(ITelegramBotClient botClient, Exception exception, CancellationToken ct)
    {
        Console.WriteLine($"Telegram Error: {exception.Message}");
        return Task.CompletedTask;
    }
}