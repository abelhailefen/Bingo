using Bingo.Core.Contract.Hub;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Gameplay.Contract.Command;
using Bingo.Core.Features.Gameplay.Contract.Query;
using Bingo.Core.Features.Gameplay.DTOs;
using Bingo.Core.Features.Rooms.Contract.Command;
using Bingo.Core.Features.Rooms.Contract.Query;
using Bingo.Core.Features.Rooms.DTOs;
using Bingo.Core.Gameplay.Contract.Command;
using Bingo.Core.Hubs;
using Bingo.Core.Models;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace Bingo.API.Controllers;

[ApiController]
[Route("api/rooms")]
public class RoomsController : ControllerBase
{
    private readonly IMediator _mediator;
    public RoomsController(IMediator mediator )
    {
        _mediator = mediator;
    }
    [HttpPost("{roomId}/claim")]
    public async Task<Response<bool>> ClaimBingo(long roomId, [FromBody] ClaimBingoRequest request)
    {
        // 1. Map the URL parameter and Body parameter to the MediatR Command
        var command = new ClaimBingoCommand(roomId, request.UserId);

        // 2. Send to the Handler
        var result = await _mediator.Send(command);

      

        return result;
    }
    [HttpPost("{roomId}/leave")]
    public async Task<ActionResult<Response<bool>>> LeaveRoom(long roomId, [FromBody] LeaveRoomRequest request)
    {
        // The handler now manages DB cleanup AND SignalR broadcasting
        var result = await _mediator.Send(new LeaveLobbyCommand(roomId, request.UserId));
        return Ok(result);
    }
    [HttpGet("{roomId}/users/{userId}/cards")]
    public async Task<ActionResult<Response<List<Card>>>> GetMyCards(long roomId, long userId)
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
    public async Task<ActionResult<Response<List<int>>>> GetTakenCards(long roomId)
    {
        // Add a query or call repo directly if simple
        var takenCards = await _mediator.Send(new GetTakenCardsQuery(roomId));
        return Ok(takenCards);
    }
    public record SelectCardRequest(int MasterCardId, bool IsLocked, long UserId);

    [HttpPost("{roomId}/select-card")]
    public async Task<ActionResult<Response<bool>>> SelectCard(long roomId, [FromBody] SelectCardRequest request)
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
    [HttpGet("{roomId}")]
    public async Task<Response<Room>> GetRoomById(long roomId)
    {
        var query = new GetRoomByIdQuery();
        query.RoomId = roomId;
        return await _mediator.Send(query);
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
        var result = await _mediator.Send(new JoinLobbyCommand(request.UserId, request.CardPrice));

        return Ok(result);
    }

    [HttpPost("purchase")]
    public async Task<ActionResult<Response<bool>>> PurchaseCards([FromBody] PurchaseCardsRequest request)
    {
        var command = new PurchaseCardsCommand(request.UserId, request.RoomId, request.MasterCardIds);
        var result = await _mediator.Send(command);
        if (result.IsFailed) return BadRequest(result);
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
    public record PurchaseCardsRequest(long UserId, long RoomId, List<int> MasterCardIds);

    public record JoinRoomRequest(long UserId, decimal CardPrice);
    public record UserRequest(long UserId);
    public record ClaimWinRequest(long UserId, long CardId, WinTypeEnum WinType);
}
