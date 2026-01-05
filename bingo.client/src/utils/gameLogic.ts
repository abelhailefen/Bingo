export type BingoCell = {
  value: number | 'FREE';
  marked: boolean;
  id: string; // unique ID for React keys
};

export type BingoBoard = BingoCell[][];

export const generateBingoBoard = (): BingoBoard => {
  const board: BingoBoard = [];
  const columns = {
    B: generateRandomNumbers(1, 15, 5),
    I: generateRandomNumbers(16, 30, 5),
    N: generateRandomNumbers(31, 45, 5),
    G: generateRandomNumbers(46, 60, 5),
    O: generateRandomNumbers(61, 75, 5),
  };

  // Transpose columns to rows for easier rendering
  for (let row = 0; row < 5; row++) {
    const rowCells: BingoCell[] = [];
    rowCells.push({ value: columns.B[row], marked: false, id: `B-${row}` });
    rowCells.push({ value: columns.I[row], marked: false, id: `I-${row}` });
    
    // N column (center is FREE)
    if (row === 2) {
      rowCells.push({ value: 'FREE', marked: true, id: `N-${row}` });
    } else {
      rowCells.push({ value: columns.N[row], marked: false, id: `N-${row}` });
    }

    rowCells.push({ value: columns.G[row], marked: false, id: `G-${row}` });
    rowCells.push({ value: columns.O[row], marked: false, id: `O-${row}` });
    board.push(rowCells);
  }

  return board;
};

const generateRandomNumbers = (min: number, max: number, count: number): number[] => {
  const numbers = new Set<number>();
  while (numbers.size < count) {
    numbers.add(Math.floor(Math.random() * (max - min + 1)) + min);
  }
  return Array.from(numbers);
};

export const checkWin = (board: BingoBoard): boolean => {
  const size = 5;

  // Check rows
  for (let row = 0; row < size; row++) {
    if (board[row].every(cell => cell.marked)) return true;
  }

  // Check columns
  for (let col = 0; col < size; col++) {
    if (board.every(row => row[col].marked)) return true;
  }

  // Check diagonals
  if (board.every((row, i) => row[i].marked)) return true;
  if (board.every((row, i) => row[size - 1 - i].marked)) return true;

  return false;
};

export const getBingoLetter = (num: number): string => {
  if (num <= 15) return 'B';
  if (num <= 30) return 'I';
  if (num <= 45) return 'N';
  if (num <= 60) return 'G';
  return 'O';
};
