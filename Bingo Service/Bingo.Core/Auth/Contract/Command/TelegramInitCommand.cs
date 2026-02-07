using Bingo.Core.Auth.Contract.Response;
using MediatR;
using Bingo.Core.Models;
namespace Bingo.Core.Auth.Contract.Command;

public record TelegramInitCommand(string InitData) : IRequest<Response<TelegramInitResponse>>;
