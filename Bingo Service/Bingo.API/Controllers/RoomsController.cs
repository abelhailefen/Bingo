using Bingo.Core.Contract.Hub;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Features.Gameplay.Contract.Query;
using Bingo.Core.Features.Gameplay.DTOs;
using Bingo.Core.Features.Rooms.Contract.Command;
using Bingo.Core.Features.Rooms.Contract.Query;
using Bingo.Core.Features.Rooms.DTOs;
using Bingo.Core.Models;
using Bingo.Core.Hubs;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace Bingo.API.Controllers;

[ApiController]
[Route("api/rooms")]
public class RoomsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IHubContext<BingoHub, IBingoHubClient> _hubContext;
    public RoomsController(IMediator mediator, IHubContext<BingoHub, IBingoHubClient> hubContext)
    {
        _mediator = mediator;
        _hubContext = hubContext;
    }
    [HttpGet("{roomId}/users/{userId}/cards")]
    public async Task<IActionResult> GetMyCards(long roomId, long userId)
    {
        var result = await _mediator.Send(new GetMyCardsQuery(roomId, userId));
        return Ok(result);
    }

    [HttpGet("{roomId}/master-card/{masterCardId}")]
    public async Task<ActionResult<Response<MasterCardDto>>> GetMasterCard(long roomId, int masterCardId)
    {
        var result = await _mediator.Send(new GetMasterCardQuery(roomId, masterCardId));
        if (result.IsFailed)
        {
            return BadRequest(result);
        }
        return Ok(result);
    }
    [HttpGet("{roomId}/taken-cards")]
    public async Task<IActionResult> GetTakenCards(long roomId)
    {
        // Add a query or call repo directly if simple
        var takenCards = await _mediator.Send(new GetTakenCardsQuery(roomId));
        return Ok(takenCards);
    }
    public record SelectCardRequest(int MasterCardId, bool IsLocked, long UserId);

    [HttpPost("{roomId}/select-card")]
    public async Task<IActionResult> SelectCard(long roomId, [FromBody] SelectCardRequest request)
    {
        // Ensure you are passing the request.UserId to the command
        var result = await _mediator.Send(new SelectCardCommand(
            roomId,
            request.UserId,
            request.MasterCardId,
            request.IsLocked));

        if (result.IsFailed) return BadRequest(result);
        return Ok(result);
    }
    [HttpGet("{roomId}/state")]
    public async Task<ActionResult<Response<RoomStateDto>>> GetRoomState(long roomId)
    {
        var result = await _mediator.Send(new GetRoomStateQuery(roomId));
        if (result.IsFailed) return NotFound(result);
        return Ok(result);
    }
    [HttpPost("lobby/join")]
    public async Task<ActionResult<Response<JoinLobbyResponse>>> JoinLobby([FromBody] JoinRoomRequest request)
    {
        var result = await _mediator.Send(new JoinLobbyCommand(request.UserId));

        // After joining, we need to know which cards are already taken
        // You can either include this in JoinLobbyCommand's result 
        // or add a specific endpoint below
        return Ok(result);
    }

    [HttpPost("lobby/confirm")]
    public async Task<ActionResult<Response<string>>> ConfirmSelection([FromBody] ConfirmSelectionRequest request)
    {
        var result = await _mediator.Send(new ConfirmSelectionCommand(request.UserId, request.RoomId, request.MasterCardIds));
        if (result.IsFailed) return BadRequest(result);
        return Ok(result);
    }

    public record ConfirmSelectionRequest(long UserId, long RoomId, List<int> MasterCardIds);

    public record JoinRoomRequest(long UserId);
    public record UserRequest(long UserId);
    public record ClaimWinRequest(long UserId, long CardId, WinTypeEnum WinType);
}
