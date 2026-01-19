export const formatBackendCard = (backendNumbers: any[]): BingoBoard => {
    const grid: BingoBoard = Array(5).fill(null).map(() => Array(5).fill(null));

    backendNumbers.forEach((num) => {
        const r = num.positionRow - 1;
        const c = num.positionCol - 1;

        if (r >= 0 && r < 5 && c >= 0 && c < 5) {
            // Check if number is null (Center Square)
            const isCenter = num.number === null;
            
            grid[r][c] = {
                id: isCenter ? `free-${r}-${c}` : `${num.number}-${r}-${c}`,
                value: isCenter ? '★' : num.number,
                // Center is ALWAYS marked. Otherwise use the synced state.
                marked: isCenter ? true : (num.isMarked ?? false) 
            };
        }
    });

    return grid;
};

export const checkWin = (board: BingoBoard): boolean => {
    // 1. Check Rows
    for (let r = 0; r < 5; r++) {
        if (board[r].every(cell => cell && cell.marked)) return true;
    }
    
    // 2. Check Columns
    for (let c = 0; c < 5; c++) {
        let colWin = true;
        for (let r = 0; r < 5; r++) {
            if (!board[r][c] || !board[r][c].marked) {
                colWin = false;
                break;
            }
        }
        if (colWin) return true;
    }

    // 3. Check Diagonals
    const d1 = [0, 1, 2, 3, 4].every(i => board[i][i] && board[i][i].marked);
    const d2 = [0, 1, 2, 3, 4].every(i => board[i][4 - i] && board[i][4 - i].marked);

    return d1 || d2;
};