using Bingo.Core.Entities.Enums; 
using Bingo.Infrastructure.Context;
using Microsoft.EntityFrameworkCore;
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

namespace Bingo.Infrastructure.Service;

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
                var webAppUrl = "https://bingo-beta-one.vercel.app/";

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
                    var db = scope.ServiceProvider.GetRequiredService<BingoDbContext>();
                    await CreateRoomCommand(chatId, db, botClient, ct);
                }
                break;

            case "/join":
                var code = messageText.Split(' ').Length > 1 ? messageText.Split(' ')[1] : "";
                using (var scope = _scopeFactory.CreateScope())
                {
                    var db = scope.ServiceProvider.GetRequiredService<BingoDbContext>();
                    await JoinRoomCommand(chatId, code, db, botClient, message.From?.Username ?? "Player", ct);
                }
                break;
        }
    }

    private async Task CreateRoomCommand(long chatId, BingoDbContext db, ITelegramBotClient botClient, CancellationToken ct)
    {
        var user = await db.Users.FirstOrDefaultAsync(u => u.Username == chatId.ToString(), ct);
        if (user == null)
        {
            user = new BingoUser
            {
                Username = chatId.ToString(),
                PhoneNumber = $"{chatId}@telegram.com",
                PasswordHash = "TG_USER",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            db.Users.Add(user);
            await db.SaveChangesAsync(ct);
        }

        var room = new BingoRoom
        {
            Name = $"TG Room {chatId}",
            RoomCode = Guid.NewGuid().ToString()[..6].ToUpper(),
            HostUserId = user.UserId,
            Status = RoomStatusEnum.Waiting,
            CreatedAt = DateTime.UtcNow
        };

        db.Rooms.Add(room);
        await db.SaveChangesAsync(ct);

        await botClient.SendMessage(chatId, $"Room Created!\nCode: {room.RoomCode}", cancellationToken: ct);
    }

    private async Task JoinRoomCommand(long chatId, string code, BingoDbContext db, ITelegramBotClient botClient, string username, CancellationToken ct)
    {
        var room = await db.Rooms.FirstOrDefaultAsync(r => r.RoomCode == code, ct);
        if (room == null)
        {
            await botClient.SendMessage(chatId, "Room not found!", cancellationToken: ct);
            return;
        }

        await botClient.SendMessage(chatId, $"Joining room {room.Name}...", cancellationToken: ct);
    }

    // THIS METHOD MUST BE INSIDE THE CLASS BRACES
    private Task HandlePollingErrorAsync(ITelegramBotClient botClient, Exception exception, CancellationToken ct)
    {
        Console.WriteLine($"Telegram Error: {exception.Message}");
        return Task.CompletedTask;
    }
}