using MediatR;
using Bingo.Core.Models;
using Bingo.Core.Entities;

namespace Bingo.Core.Auth.Contract.Query;

public record GetUserProfileQuery(long UserId) : IRequest<Response<User>>;
