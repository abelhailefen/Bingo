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
            // Add the free space (null/0) to called numbers for checking
            var drawn = calledNumbers.ToHashSet();
            drawn.Add(0); // Assuming 0 or null is the middle star

            // Helper to get number at specific row/col (1-indexed)
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
