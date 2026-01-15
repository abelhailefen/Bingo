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

namespace Bingo.Core.Auth.Handler;

public class TelegramInitCommandHandler : IRequestHandler<TelegramInitCommand, Response<string>>
{
    private readonly IBingoRepository _repository;
    private readonly string _botToken;

    public TelegramInitCommandHandler(IBingoRepository repository, IConfiguration configuration)
    {
        _repository = repository;
        _botToken = configuration["TelegramBot:Token"] ?? throw new ArgumentNullException("TelegramBot:Token not configured");
    }

    public async Task<Response<string>> Handle(TelegramInitCommand request, CancellationToken cancellationToken)
    {
        // 1. Parse and Validate InitData
        if (!ValidateInitData(request.InitData, _botToken, out var userJson))
        {
             return Response<string>.Error("Invalid Telegram authentication data");
        }
        
        TelegramUser? tgUser;
        try
        {
            tgUser = JsonSerializer.Deserialize<TelegramUser>(userJson);
        }
        catch (JsonException)
        {
            return Response<string>.Error("Invalid init data: user json invalid");
        }

        if (tgUser == null)
        {
             return Response<string>.Error("Invalid init data: user data null");
        }

        // 2. Find or Create User
        var user = await _repository.FindOneAsync<User>(u => u.UserId == tgUser.Id);

        if (user == null)
        {
            // Create new user
            user = new User
            {
                UserId = tgUser.Id, 
                Username = tgUser.Username ?? $"User_{tgUser.Id}",
                PhoneNumber = "N/A",
                PasswordHash = "telegram_auth",
                Balance = 0
            };
            
            await _repository.AddAsync(user);
            await _repository.SaveChanges();
        }

        // 3. Generate Token
        // For MVP returning UserId. In production, use JWT.
        return Response<string>.Success($"Token_For_{user.UserId}");
    }

    private bool ValidateInitData(string initData, string botToken, out string userJson)
    {
        userJson = "";
        try 
        {
            var parsed = HttpUtility.ParseQueryString(initData);
            var dataCheckArr = new List<string>();
            string? hash = null;

            foreach (string key in parsed.AllKeys)
            {
                if (key == "hash")
                {
                    hash = parsed[key];
                    continue;
                }
                
                if (key == "user")
                {
                    userJson = parsed[key]!;
                }

                dataCheckArr.Add($"{key}={parsed[key]}");
            }

            if (string.IsNullOrEmpty(hash) || string.IsNullOrEmpty(userJson)) return false;

            // Sort alphabetically
            dataCheckArr.Sort();
            var dataCheckString = string.Join("\n", dataCheckArr);

            // HMAC-SHA256
            var secretKey = HMACSHA256.HashData(Encoding.UTF8.GetBytes("WebAppData"), Encoding.UTF8.GetBytes(botToken));
            var calculatedHashBytes = HMACSHA256.HashData(secretKey, Encoding.UTF8.GetBytes(dataCheckString));
            var calculatedHash = Convert.ToHexString(calculatedHashBytes).ToLower();

            // Hash must be lower-case hex string
            // InitData hash is usually lower case hex
            
            return calculatedHash == hash;
        }
        catch
        {
            return false;
        }
    }

    private class TelegramUser 
    {
        [JsonPropertyName("id")]
        public long Id { get; set; }
        
        [JsonPropertyName("first_name")]
        public string FirstName { get; set; } = "";
        
        [JsonPropertyName("last_name")]
        public string? LastName { get; set; }
        
        [JsonPropertyName("username")]
        public string? Username { get; set; }
        
        [JsonPropertyName("language_code")]
        public string? LanguageCode { get; set; }
    }
}
