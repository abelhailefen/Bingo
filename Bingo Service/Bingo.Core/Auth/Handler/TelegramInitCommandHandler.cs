using MediatR;
using Bingo.Core.Auth.Contract.Command;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Web;

namespace Bingo.Core.Auth.Handler;

public class TelegramInitCommandHandler : IRequestHandler<TelegramInitCommand, Response<string>>
{
    private readonly IBingoRepository _repository;

    public TelegramInitCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<string>> Handle(TelegramInitCommand request, CancellationToken cancellationToken)
    {
        // 1. Parse InitData
        // InitData is a query string like: query_id=...&user=%7B%22id%22%3A123%2C%22first_name%22%3A%22Name%22%7D&auth_date=...&hash=...
        
        var parsed = HttpUtility.ParseQueryString(request.InitData);
        var userJson = parsed["user"];
        
        if (string.IsNullOrEmpty(userJson))
        {
             return Response<string>.Error("Invalid init data: user field missing");
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

        // TODO: Validate Hash using Bot Token (security)
        // For now, we trust the data as this is an MVP/internal use or handled by API Gateway? 
        // Ideally verify HMAC-SHA256 signature.

        // 2. Find or Create User
        // Use UserId == TelegramId assumption per schema discussion
        var user = await _repository.FindOneAsync<User>(u => u.UserId == tgUser.Id);

        if (user == null)
        {
            // Create new user
            user = new User
            {
                UserId = tgUser.Id, 
                Username = tgUser.Username ?? $"User_{tgUser.Id}",
                PhoneNumber = "N/A", // Placeholder
                PasswordHash = "telegram_auth", // Placeholder
                Balance = 0
            };
            
            await _repository.AddAsync(user);
            await _repository.SaveChanges();
        }

        // 3. Generate Token
        // For now return a dummy token or just the UserId as a string
        return Response<string>.Success($"Token_For_{user.UserId}");
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
