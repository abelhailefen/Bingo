/*using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Entities.Enums;
using Bingo.Core.Features.Rooms.Contract.Command;
using Bingo.Core.Features.Rooms.DTOs;
using Bingo.Core.Models;
using Bingo.Core.Services;
using MediatR;
using System.Security.Cryptography;

namespace Bingo.Core.Features.Rooms.Handler
{

    public class JoinRoomCommandHandler : IRequestHandler<JoinRoomCommand, Response<JoinLobbyResponse>>
    {
        private readonly IBingoRepository _repo;

        public JoinRoomCommandHandler(IBingoRepository repository)
        {
            _repo = repository;
        }

        public async Task<Response<JoinLobbyResponse>> Handle(JoinRoomCommand request, CancellationToken ct)
        {
            // 1. Find a room that is Waiting and not full (MaxPlayers default 100)
            var room = await _repo.FindOneAsync<Room>(r =>
                r.Status == RoomStatusEnum.Waiting &&
                r.Players.Count < r.MaxPlayers);

            if (room == null)
            {
                // 2. No room found? Create one automatically
                room = new Room
                {
                    Name = $"Quick Game {DateTime.UtcNow.Ticks}",
                    RoomCode = GenerateRandomCode(),
                    Status = RoomStatusEnum.Waiting,
                    HostUserId = request.UserId // First person is technically the "host"
                };
                await _repo.AddAsync(room);
                await _repo.SaveChanges();
            }
            JoinLobbyResponse response = new JoinLobbyResponse
            {
                RooomId = room.RoomId
            };

            return Response<JoinLobbyResponse>.Success(response);
        }


        public static string GenerateRandomCode(int length = 8)
        {
            const string letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            var bytes = new byte[length];
            var result = new char[length];

            RandomNumberGenerator.Fill(bytes);

            for (int i = 0; i < length; i++)
            {
                result[i] = letters[bytes[i] % letters.Length];
            }

            return new string(result);
        }
    }
}*/