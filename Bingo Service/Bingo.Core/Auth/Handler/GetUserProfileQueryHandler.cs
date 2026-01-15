using MediatR;
using Bingo.Core.Auth.Contract.Query;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using Bingo.Core.Contract.Repository;

namespace Bingo.Core.Auth.Handler;

public class GetUserProfileQueryHandler : IRequestHandler<GetUserProfileQuery, Response<User>>
{
    private readonly IBingoRepository _repository;

    public GetUserProfileQueryHandler(IBingoRepository repository)
    {
        _repository = repository;
    }

    public async Task<Response<User>> Handle(GetUserProfileQuery request, CancellationToken cancellationToken)
    {
        var user = await _repository.GetUserWithDetailsAsync(request.UserId);
            
        if (user == null)
        {
            return Response<User>.NotFound("User not found");
        }
        
        return Response<User>.Success(user);
    }
}
