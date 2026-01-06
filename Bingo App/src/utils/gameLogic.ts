import type { CardNumber } from '../services/api';

export type BingoCell = {
    value: number | 'FREE';
    marked: boolean;
    id: string;
};

export type BingoBoard = BingoCell[][];

/**
 * Converts the flat array of CardNumbers from the backend 
 * into a 5x5 grid for the UI.
 */
export const formatBackendCard = (backendNumbers: CardNumber[]): BingoBoard => {
    // Create empty 5x5 grid
    const grid: BingoBoard = Array(5).fill(null).map(() => Array(5).fill(null));

    backendNumbers.forEach(n => {
        // Backend uses 1-5, JS uses 0-4
        const r = n.positionRow - 1;
        const c = n.positionCol - 1;

        grid[r][c] = {
            value: n.number === 0 ? 'FREE' : n.number,
            marked: n.isMarked || n.number === 0,
            id: `${n.positionRow}-${n.positionCol}`
        };
    });

    return grid;
};

/**
 * Standard Bingo Win Logic (Rows, Columns, Diagonals)
 */
export const checkWin = (board: BingoBoard): boolean => {
    if (!board || board.length === 0) return false;
    const size = 5;

    // Check rows
    for (let r = 0; r < size; r++) {
        if (board[r].every(cell => cell.marked)) return true;
    }

    // Check columns
    for (let c = 0; c < size; c++) {
        if (board.every(row => row[c].marked)) return true;
    }

    // Check diagonals
    if (board.every((row, i) => row[i].marked)) return true;
    if (board.every((row, i) => row[size - 1 - i].marked)) return true;

    return false;
};

/**
 * Returns B, I, N, G, or O based on the number
 */
export const getBingoLetter = (num: number | null): string => {
    if (!num || num === 0) return '';
    if (num <= 15) return 'B';
    if (num <= 30) return 'I';
    if (num <= 45) return 'N';
    if (num <= 60) return 'G';
    return 'O';
};