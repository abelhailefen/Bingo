using Bingo.Core.Gameplay.Contract.Command;
using Bingo.Core.Contract.Repository;
using Bingo.Core.Entities;
using Bingo.Core.Models;
using MediatR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Gameplay.Handler.Command
{
    public class BuyCardsCommandHandler : IRequestHandler<BuyCardsCommand, Response<List<Card>>>
    {
        private readonly IBingoRepository _repo;

        public BuyCardsCommandHandler(IBingoRepository repo)
        {
            _repo = repo;
        }

        public async Task<Response<List<Card>>> Handle(BuyCardsCommand request, CancellationToken ct)
        {
            var room = await _repo.FindOneAsync<Room>(r =>r.RoomId == request.RoomId);
            var user = await _repo.FindOneAsync<User>(r => r.UserId == request.RoomId);

            decimal totalCost = room.CardPrice * request.Quantity;
            if (user.Balance < totalCost) return Response<List<Card>>.Error("Insufficient balance");

            user.Balance -= totalCost;
            var cards = new List<Card>();

            for (int i = 0; i < request.Quantity; i++)
            {
                var matrix = GenerateBingoMatrix();
                cards.Add(await _repo.CreateCardWithNumbersAsync(user.UserId, room.RoomId, matrix));
            }

            return Response<List<Card>>.Success(cards);
        }

        private List<List<int>> GenerateBingoMatrix()
        {
            // Standard Bingo: Col 0 (1-15), Col 1 (16-30)...
            var rng = new Random();
            var matrix = Enumerable.Range(0, 5).Select(_ => new List<int>(new int[5])).ToList();
            for (int col = 0; col < 5; col++)
            {
                var nums = Enumerable.Range(col * 15 + 1, 15).OrderBy(_ => rng.Next()).Take(5).ToList();
                for (int row = 0; row < 5; row++) matrix[row][col] = nums[row];
            }
            matrix[2][2] = 0; // Center Free Space
            return matrix;
        }
    }
}
