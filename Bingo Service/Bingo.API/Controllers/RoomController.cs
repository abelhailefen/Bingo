using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Models;
using Bingo.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Bingo.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RoomsController : ControllerBase
{
    private readonly BingoDbContext _context;

    public RoomsController(BingoDbContext context)
    {
        _context = context;
    }

    /* [HttpPost]
     public async Task<ActionResult<Room>> CreateRoom([FromBody] string roomName, [FromQuery] long hostUserId)
     {
         var room = new Room
         {
             Name = roomName,
             RoomCode = Guid.NewGuid().ToString()[..8].ToUpper(), // Random 8-char code
             HostUserId = hostUserId,
             Status = RoomStatusEnum.Waiting,
             CreatedAt = DateTime.UtcNow
         };

         _context.Rooms.Add(room);
         await _context.SaveChangesAsync();

         return CreatedAtAction(nameof(GetRoom), new { id = room.RoomId }, room);
     }*/
    [HttpGet("{id}")]
    public async Task<ActionResult<Room>> GetRoom(long id)
    {
        var room = await _context.Rooms
            .Include(r => r.Players).ThenInclude(p => p.User)
            .Include(r => r.CalledNumbers)
            .Include(r => r.Cards)
                .ThenInclude(c => c.Numbers)
            .FirstOrDefaultAsync(r => r.RoomId == id);

        return room == null ? NotFound() : room;
    }

    [HttpPost("{id}/join")]
    public async Task<ActionResult> JoinRoom(long id, [FromQuery] long userId)
    {
        var room = await _context.Rooms.FindAsync(id);
        if (room == null) return NotFound("Room not found");

        // 1. Register player in room
        var roomPlayer = new RoomPlayer
        {
            RoomId = id,
            UserId = userId,
            JoinedAt = DateTime.UtcNow
        };

        // 2. Automatically generate a Bingo Card for the player
        var card = new Card
        {
            RoomId = id,
            UserId = userId,
            PurchasedAt = DateTime.UtcNow,
            Numbers = GenerateBingoCardNumbers()
        };

        _context.RoomPlayers.Add(roomPlayer);
        _context.Cards.Add(card);

        await _context.SaveChangesAsync();

        return Ok(new { RoomId = id, CardId = card.CardId });
    }

    [HttpPost("{id}/draw")]
    public async Task<ActionResult<short>> DrawNumber(long id)
    {
        var room = await _context.Rooms
            .Include(r => r.CalledNumbers)
            .FirstOrDefaultAsync(r => r.RoomId == id);

        if (room == null) return NotFound();

        var existingNumbers = room.CalledNumbers.Select(n => n.Number).ToHashSet();
        if (existingNumbers.Count >= 75) return BadRequest("All numbers drawn");

        var random = new Random();
        short nextNum;
        do
        {
            nextNum = (short)random.Next(1, 76);
        } while (existingNumbers.Contains(nextNum));

        var calledNum = new CalledNumber
        {
            RoomId = id,
            Number = nextNum,
            CalledAt = DateTime.UtcNow
        };

        _context.CalledNumbers.Add(calledNum);
        await _context.SaveChangesAsync();

        return Ok(nextNum);
    }

    private List<CardNumber> GenerateBingoCardNumbers()
    {
        var cardNumbers = new List<CardNumber>();
        var random = new Random();

        // Bingo columns: B(1-15), I(16-30), N(31-45), G(46-60), O(61-75)
        for (int col = 0; col < 5; col++)
        {
            int min = (col * 15) + 1;
            int max = (col * 15) + 15;

            var columnValues = new HashSet<int>();
            while (columnValues.Count < 5)
            {
                columnValues.Add(random.Next(min, max + 1));
            }

            var valuesList = columnValues.ToList();
            for (int row = 0; row < 5; row++)
            {
                cardNumbers.Add(new CardNumber
                {
                    PositionRow = (short)(row + 1),
                    PositionCol = (short)(col + 1),
                    Number = (col == 2 && row == 2) ? (short)0 : (short)valuesList[row], // Center Free Space
                    IsMarked = (col == 2 && row == 2)
                });
            }
        }
        return cardNumbers;
    }
    [HttpPost]
    public async Task<ActionResult<Room>> CreateRoom([FromBody] CreateRoomRequest request)
    {
        // Check if request is null or room name is empty
        if (string.IsNullOrEmpty(request.RoomName))
        {
            return BadRequest("Room name is required.");
        }

        var room = new Room
        {
            Name = request.RoomName,
            RoomCode = Guid.NewGuid().ToString()[..8].ToUpper(),
            HostUserId = request.HostUserId,
            Status = RoomStatusEnum.Waiting,
            CreatedAt = DateTime.UtcNow
        };

        _context.Rooms.Add(room);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetRoom), new { id = room.RoomId }, room);
    }
 
}