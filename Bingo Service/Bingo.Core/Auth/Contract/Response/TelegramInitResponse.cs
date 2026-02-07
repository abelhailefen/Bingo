namespace Bingo.Core.Auth.Contract.Response;

public record TelegramInitResponse(string Token, long UserId, string Username, string PhoneNumber);
