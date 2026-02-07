using MediatR;
using Bingo.Core.Auth.Contract.Command;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Web;
using Microsoft.Extensions.Configuration;
using System.Security.Cryptography;
using System.Text;

using Bingo.Core.Auth.Contract.Response;

namespace Bingo.Core.Auth.Handler;

public class TelegramInitCommandHandler : IRequestHandler<TelegramInitCommand, Response<TelegramInitResponse>>
{
    private readonly IBingoRepository _repository;
    private readonly string _botToken;

    public TelegramInitCommandHandler(IBingoRepository repository, IConfiguration configuration)
    {
        _repository = repository;
        _botToken = configuration["TelegramBot:Token"] ?? throw new ArgumentNullException("Token not found");
    }

    public async Task<Response<TelegramInitResponse>> Handle(TelegramInitCommand request, CancellationToken cancellationToken)
    {
        if (!ValidateInitData(request.InitData, _botToken, out var userJson))
        {
            return Response<TelegramInitResponse>.Error("Invalid authentication hash.");
        }

        var tgUser = JsonSerializer.Deserialize<TelegramUser>(userJson);
        if (tgUser == null) return Response<TelegramInitResponse>.Error("Invalid user data.");

        // Check if user exists (Should have been created by the Bot /start flow)
        var user = await _repository.FindOneAsync<User>(u => u.UserId == tgUser.Id);

        if (user == null)
        {
            // Auto-register the user if they don't exist
            user = new User
            {
                UserId = tgUser.Id,
                Username = tgUser.Username ?? $"User-{tgUser.Id}",
                Balance = 0, // Or a starting bonus
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                PhoneNumber = "0000000000", // Placeholder if required
                PasswordHash = "telegram-auth" // Placeholder
            };
            
            await _repository.AddAsync(user);
            await _repository.SaveChanges();
        }

        // Generate a simple token (In production use JWT)
        var token = Convert.ToBase64String(Encoding.UTF8.GetBytes($"session_{user.UserId}_{DateTime.UtcNow.Ticks}"));

        return Response<TelegramInitResponse>.Success(new TelegramInitResponse(token, user.UserId, user.Username, user.PhoneNumber));
    }

    private bool ValidateInitData(string initData, string botToken, out string userJson)
    {
        userJson = "";
        try
        {
            var parsed = HttpUtility.ParseQueryString(initData);
            var dataCheckList = new List<string>();
            string? hash = null;

            foreach (string key in parsed.AllKeys)
            {
                if (key == "hash") { hash = parsed[key]; continue; }
                if (key == "user") userJson = parsed[key]!;
                dataCheckList.Add($"{key}={parsed[key]}");
            }

            if (string.IsNullOrEmpty(hash)) return false;

            dataCheckList.Sort();
            var dataCheckString = string.Join("\n", dataCheckList);

            var secretKey = HMACSHA256.HashData(Encoding.UTF8.GetBytes("WebAppData"), Encoding.UTF8.GetBytes(botToken));
            var calculatedHash = HMACSHA256.HashData(secretKey, Encoding.UTF8.GetBytes(dataCheckString));
            var hexHash = Convert.ToHexString(calculatedHash).ToLower();

            return hexHash == hash;
        }
        catch { return false; }
    }

    private class TelegramUser
    {
        [JsonPropertyName("id")] public long Id { get; set; }
        [JsonPropertyName("username")] public string? Username { get; set; }
    }
}