using Bingo.Core.BingoGame.Contract.Command;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Models;
using Bingo.Infrastructure.Context;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Bingo.API.Controllers;
[ApiController]
[Route("api/[controller]")]
public class GameController : ControllerBase
{
    private readonly IMediator _mediator;
    public GameController(IMediator mediator) => _mediator = mediator;

   /* [HttpPost("join")]
    public async Task<IActionResult> Join([FromBody] JoinRoomCommand cmd) => Ok(await _mediator.Send(cmd));
*/
    [HttpPost("buy-cards")]
    public async Task<IActionResult> BuyCards([FromBody] BuyCardsCommand cmd) => Ok(await _mediator.Send(cmd));

   /* [HttpPost("claim-bingo")]
    public async Task<IActionResult> ClaimBingo([FromBody] ClaimBingoCommand cmd)
    {
        var result = await _mediator.Send(cmd);
        if (result.IsSuccess)
        {
            // Trigger SignalR to notify everyone that the game ended
        }
        return Ok(result);
    }

    [HttpGet("my-cards/{roomId}/{userId}")]
    public async Task<IActionResult> GetMyCards(int roomId, int userId) =>
        Ok(await _mediator.Send(new GetPlayerCardsQuery(userId, roomId)));*/
}