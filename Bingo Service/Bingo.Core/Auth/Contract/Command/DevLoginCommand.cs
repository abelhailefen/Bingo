using MediatR;
using Bingo.Core.Models;

namespace Bingo.Core.Auth.Contract.Command;

public record DevLoginCommand(long UserId, string Username) : IRequest<Response<string>>;
