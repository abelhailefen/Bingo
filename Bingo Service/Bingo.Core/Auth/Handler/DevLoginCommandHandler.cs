using MediatR;
using Bingo.Core.Auth.Contract.Command;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;

namespace Bingo.Core.Auth.Handler;

public class DevLoginCommandHandler : IRequestHandler<DevLoginCommand, Response<string>>
{
    private readonly IBingoRepository _repository;

    public DevLoginCommandHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<string>> Handle(DevLoginCommand request, CancellationToken cancellationToken)
    {
        var user = await _repository.FindOneAsync<User>(u => u.UserId == request.UserId);

        if (user == null)
        {
            user = new User
            {
                UserId = request.UserId,
                Username = request.Username,
                PhoneNumber = "DEV_USER",
                PasswordHash = "dev_auth",
                Balance = 1000 // Give some dev money
            };

            try
            {
                await _repository.AddAsync(user);
                await _repository.SaveChanges();
            }
            catch
            {
                // Ignore race conditions (User might have been created by another request)
            }
        }

        return Response<string>.Success($"Token_For_{request.UserId}");
    }
}
