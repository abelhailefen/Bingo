using Bingo.Core.Entities;

namespace Bingo.Core.Services;

public static class CardGenerator
{
    public static Card GenerateCard(long roomId, long userId)
    {
        var card = new Card
        {
            RoomId = roomId,
            UserId = userId,
            PurchasedAt = DateTime.UtcNow
        };

        var random = new Random();
        var numbers = new List<CardNumber>();

        // Bingo 75-ball standard
        // Col 1 (B): 1-15
        // Col 2 (I): 16-30
        // Col 3 (N): 31-45
        // Col 4 (G): 46-60
        // Col 5 (O): 61-75

        for (int col = 0; col < 5; col++)
        {
            int min = (col * 15) + 1;
            int max = min + 15;
            
            var colNumbers = Enumerable.Range(min, 15).OrderBy(x => random.Next()).Take(5).ToList();

            for (int row = 0; row < 5; row++)
            {
                // Middle spot (row 2, col 2) is typically Free in 75-ball, but standard schema treats it as a number? 
                // Or maybe we treat it as Marked automatically?
                // Let's assume standard random numbers for now. 
                // If it needs to be free space, usually it's marked or has a special value (e.g. 0).
                // Schema has `number SMALLINT`.
                
                var number = colNumbers[row];
                bool isMarked = false;

                // Free space logic: Row 3 (index 2), Col 3 (index 2)
                if (row == 2 && col == 2)
                {
                    // If we want FREE space
                     isMarked = true; // Mark it automatically?
                     // Verify if we want a number there. Usually yes, or 0.
                     // I'll leave the number there but mark it used/free?
                     // Or maybe for this MVP we just generate numbers.
                }

                numbers.Add(new CardNumber
                {
                    PositionRow = (short)(row + 1),
                    PositionCol = (short)(col + 1),
                    Number = (short)number,
                    IsMarked = isMarked
                });
            }
        }
        
        card.Numbers = numbers;
        return card;
    }
}
