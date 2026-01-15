using MediatR;
using Bingo.Core.Features.Admin.Contract.Query;
using Bingo.Core.Models;
using Microsoft.AspNetCore.Mvc;

namespace Bingo.API.Controllers;

[ApiController]
[Route("api/admin")]
public class AdminController : ControllerBase
{
    private readonly IMediator _mediator;

    public AdminController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("stats")]
    public async Task<ActionResult<Response<SystemStatsDto>>> GetStats()
    {
        // TODO: Add Admin Authorization (Role based auth)
        var result = await _mediator.Send(new GetSystemStatsQuery());
        return Ok(result);
    }
}
