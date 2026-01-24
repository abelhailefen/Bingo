using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bingo.Core.Services
{
    public static class WinVerificationService
    {
        public static bool IsValidWin(List<int> cardNumbers, List<int> calledNumbers)
        {
            if (cardNumbers.Count != 25) return false;

            var drawn = calledNumbers.ToHashSet();
            // Index 12 is the 13th element (3rd row, 3rd column)
            int freeSpaceValue = cardNumbers[12];
            drawn.Add(freeSpaceValue);

            int GetNum(int r, int c) => cardNumbers[(r - 1) * 5 + (c - 1)];

            // Check Rows
            for (int r = 1; r <= 5; r++)
                if (Enumerable.Range(1, 5).All(c => drawn.Contains(GetNum(r, c)))) return true;

            // Check Columns
            for (int c = 1; c <= 5; c++)
                if (Enumerable.Range(1, 5).All(r => drawn.Contains(GetNum(r, c)))) return true;

            // Check Diagonals
            if (Enumerable.Range(1, 5).All(i => drawn.Contains(GetNum(i, i)))) return true;
            if (Enumerable.Range(1, 5).All(i => drawn.Contains(GetNum(i, 6 - i)))) return true;

            return false;
        }
    }
}
