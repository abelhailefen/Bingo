import { useState, useEffect, useCallback } from 'react';
import confetti from 'canvas-confetti';
import type { BingoBoard as BingoBoardType } from './utils/gameLogic';
import {
    generateBingoBoard,
    checkWin
} from './utils/gameLogic';
import { BingoBoard } from './components/BingoBoard';
import { ControlPanel } from './components/ControlPanel';
import { GameStatus } from './components/GameStatus';

function App() {
    const [board, setBoard] = useState<BingoBoardType>(generateBingoBoard());
    const [drawnNumbers, setDrawnNumbers] = useState<number[]>([]);
    const [currentNumber, setCurrentNumber] = useState<number | null>(null);
    const [gameWon, setGameWon] = useState(false);
    const [gameActive, setGameActive] = useState(false); // Game starts when user clicks "New Game" or on load? Let's say active by default for simplicity, or "Start" state.

    // Initialize game on load
    useEffect(() => {
        startNewGame();
    }, []);

    const startNewGame = () => {
        setBoard(generateBingoBoard());
        setDrawnNumbers([]);
        setCurrentNumber(null);
        setGameWon(false);
        setGameActive(true);
    };

    const drawNumber = useCallback(() => {
        if (!gameActive || drawnNumbers.length >= 75) return;

        let nextNum;
        do {
            nextNum = Math.floor(Math.random() * 75) + 1;
        } while (drawnNumbers.includes(nextNum));

        setDrawnNumbers(prev => [...prev, nextNum]);
        setCurrentNumber(nextNum);
    }, [gameActive, drawnNumbers]);

    const handleCellClick = (rowIndex: number, colIndex: number) => {
        if (!gameActive || gameWon) return;

        setBoard(prevBoard => {
            const newBoard = [...prevBoard.map(row => [...row])]; // Deep copy structure
            const cell = newBoard[rowIndex][colIndex];

            // Toggle mark
            // Note: In real bingo, you toggle. Logic checks if it's called? 
            // USUALLY digital bingo auto-daubs or lets you daub any. 
            // Let's allow daubing freely for this "Player Card" simulator, 
            // OR restrict to only called numbers?
            // For a fun UI, let's allow toggling freely (maybe user missed a call).

            // Update: Let's enforce that you can only mark if it's been called (or is free) for "Strict Mode"
            // But for better UX in a solo game, free toggling is often less frustrating if you missed one.
            // However, to make it a "Game", let's leave it toggleable at will.

            newBoard[rowIndex][colIndex] = { ...cell, marked: !cell.marked };

            // Check win condition immediately after update
            if (checkWin(newBoard)) {
                handleWin();
            }

            return newBoard;
        });
    };

    const handleWin = () => {
        if (gameWon) return; // Already won
        setGameWon(true);
        confetti({
            particleCount: 150,
            spread: 70,
            origin: { y: 0.6 },
            colors: ['#ff0000', '#00ff00', '#0000ff', '#ffff00', '#ff00ff']
        });

        // Play sound? (Optional, skipping for now)
    };

    return (
        <div className="min-h-screen flex flex-col items-center py-8 px-4 sm:px-8">

            {/* Header */}
            <header className="mb-8 text-center">
                <h1 className="text-5xl sm:text-7xl font-black text-transparent bg-clip-text bg-gradient-to-r from-pink-500 via-red-500 to-yellow-500 drop-shadow-sm tracking-tighter">
                    BINGO
                </h1>
                <p className="text-slate-400 font-medium">React Edition</p>
            </header>

            <main className="w-full max-w-6xl flex flex-col lg:flex-row gap-8 lg:gap-16 items-start justify-center">

                {/* Left Column: Game Board */}
                <div className="flex-1 w-full max-w-xl mx-auto lg:mx-0 flex flex-col gap-6">
                    <BingoBoard
                        board={board}
                        onCellClick={handleCellClick}
                        gameActive={!gameWon}
                    />

                    {gameWon && (
                        <div className="bg-gradient-to-r from-yellow-400 to-orange-500 p-4 rounded-xl text-center shadow-lg animate-bounce">
                            <span className="text-2xl font-black text-white uppercase tracking-widest">Bingo! You Win!</span>
                        </div>
                    )}
                </div>

                {/* Right Column: Controls & Status */}
                <div className="flex-1 w-full max-w-sm mx-auto lg:mx-0 flex flex-col gap-6">
                    <ControlPanel
                        onDraw={drawNumber}
                        onReset={startNewGame}
                        gameActive={gameActive && !gameWon}
                        drawnCount={drawnNumbers.length}
                    />
                    <GameStatus
                        currentNumber={currentNumber}
                        drawnNumbers={drawnNumbers}
                    />
                </div>

            </main>

        </div>
    );
}

export default App;