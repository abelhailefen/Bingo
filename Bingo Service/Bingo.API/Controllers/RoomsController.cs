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

    [HttpPost("create")]
    public async Task<ActionResult<Response<CreateRoomResponse>>> CreateRoom([FromBody] CreateRoomCommand command)
    {
        var result = await _mediator.Send(command);
        if (result.IsFailed)
        {
            return BadRequest(result);
        }
        return Ok(result);
    }

    [HttpGet("list")]
    public async Task<ActionResult<Response<List<RoomSummaryDto>>>> GetRooms([FromQuery] RoomStatusEnum? status)
    {
        var result = await _mediator.Send(new GetRoomsQuery(status));
        return Ok(result);
    }

    [HttpGet("{roomId}")]
    public async Task<ActionResult<Response<Room>>> GetRoomDetails(long roomId)
    {
        var result = await _mediator.Send(new GetRoomDetailsQuery(roomId));
        if (result.IsFailed)
        {
            return NotFound(result);
        }
        return Ok(result);
    }

 

    [HttpPost("{roomId}/leave")]
    public async Task<ActionResult<Response<string>>> LeaveRoom(long roomId, [FromBody] UserRequest request)
    {
        var result = await _mediator.Send(new LeaveRoomCommand(roomId, request.UserId));
        if (result.IsFailed) return BadRequest(result);
        return Ok(result);
    }

    [HttpPost("{roomId}/start")]
    public async Task<ActionResult<Response<string>>> StartRoom(long roomId, [FromBody] UserRequest request)
    {
        var result = await _mediator.Send(new StartRoomCommand(roomId, request.UserId));
        if (result.IsFailed) return BadRequest(result);
        return Ok(result);
    }

    [HttpPost("{roomId}/end")]
    public async Task<ActionResult<Response<string>>> EndRoom(long roomId, [FromBody] UserRequest request)
    {
        var result = await _mediator.Send(new EndRoomCommand(roomId, request.UserId));
        if (result.IsFailed) return BadRequest(result);
        return Ok(result);
    }

    [HttpGet("{roomId}/card")]
    public async Task<ActionResult<Response<List<Card>>>> GetMyCards(long roomId, [FromQuery] long userId)
    {
        var result = await _mediator.Send(new GetPlayerCardsQuery(roomId, userId));
        if (result.IsFailed) return BadRequest(result);
        return Ok(result);
    }

    [HttpPost("{roomId}/draw")]
    public async Task<ActionResult<Response<short>>> DrawNumber(long roomId, [FromBody] UserRequest request)
    {
        var result = await _mediator.Send(new DrawNumberCommand(roomId, request.UserId));
        if (result.IsFailed) return BadRequest(result);
        return Ok(result);
    }

    [HttpPost("{roomId}/claim")]
    public async Task<ActionResult<Response<Win>>> ClaimWin(long roomId, [FromBody] ClaimWinRequest request)
    {
        var command = new ClaimWinCommand(roomId, request.UserId, request.CardId, request.WinType);
        var result = await _mediator.Send(command);
        if (result.IsFailed) return BadRequest(result);
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
    [HttpPost("{roomId}/select-card")]
    public async Task<IActionResult> SelectCard(long roomId, [FromBody] SelectCardRequest request)
    {
        // Broadcast to everyone in the room group that this card is being viewed
        await _hubContext.Clients.Group(roomId.ToString())
            .CardSelectionChanged(request.MasterCardId, request.IsLocked, request.UserId);

        return Ok(Response<string>.Success("Broadcasting"));
    }

    public record SelectCardRequest(int MasterCardId, bool IsLocked, long UserId);
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
