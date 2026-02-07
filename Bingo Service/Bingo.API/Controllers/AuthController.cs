using Bingo.Core.Auth.Contract.Command;

using Bingo.Core.Auth.Contract.Query;
using Bingo.Core.Models;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Bingo.Core.Auth.Contract.Response;

namespace Bingo.API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IMediator _mediator;

    public AuthController(IMediator mediator)
    {
        _mediator = mediator;
    }


    [HttpPost("telegram-init")]
    public async Task<ActionResult<Response<TelegramInitResponse>>> TelegramInit([FromBody] TelegramInitRequest request)
    {
        var command = new TelegramInitCommand(request.InitData);
        var result = await _mediator.Send(command);
        if (result.IsFailed)
        {
            return BadRequest(result);
        }
        return Ok(result);
    }

    [HttpGet("user")]
    public async Task<ActionResult<Response<Bingo.Core.Entities.User>>> GetUser()
    {
        // TODO: Extract User ID from Token/Claims
        // For now, assuming a header "X-User-Id" for testing or extract from mock token?
        // Let's assume the client sends the userId as a query param for this MVP stage if auth header is not set up
        
        if (!Request.Headers.TryGetValue("X-User-Id", out var userIdVal) || !long.TryParse(userIdVal, out var userId))
        {
             // Fallback for testing: check query
             if (!long.TryParse(Request.Query["userId"], out userId))
             {
                 return Unauthorized(Response<object>.Error("Missing User Id"));
             }
        }

        var result = await _mediator.Send(new GetUserProfileQuery(userId));
        if (result.IsFailed)
        {
            return NotFound(result);
        }
        return Ok(result);
    }
    
    public record TelegramInitRequest(string InitData);

    [HttpPost("dev-login")]
    public async Task<ActionResult<Response<string>>> DevLogin([FromBody] DevLoginCommand command)
    {
        var result = await _mediator.Send(command);
        return Ok(result);
    }
}
