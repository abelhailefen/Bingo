using Bingo.Core.Auth.Contract.Response;

namespace Bingo.Core.Auth.Contract.Command;

public record TelegramInitCommand(string InitData) : IRequest<Response<TelegramInitResponse>>;
