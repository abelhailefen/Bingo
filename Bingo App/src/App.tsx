import { useState, useEffect } from 'react';
import confetti from 'canvas-confetti';
import { BingoBoard } from './components/BingoBoard';
import { ControlPanel } from './components/ControlPanel';
import { GameStatus } from './components/GameStatus';
import { createRoom, joinRoom, getRoom, drawNumber } from './services/api';
import { formatBackendCard, checkWin } from './utils/gameLogic';

// Access Telegram WebApp
const tg = (window as any).Telegram?.WebApp;

function App() {
    const [board, setBoard] = useState<any[][]>([]);
    const [drawnNumbers, setDrawnNumbers] = useState<number[]>([]);
    const [currentNumber, setCurrentNumber] = useState<number | null>(null);
    const [gameWon, setGameWon] = useState(false);
    const [roomId, setRoomId] = useState<number | null>(null);
    const [loading, setLoading] = useState(false);

    // Initialize Telegram
    useEffect(() => {
        if (tg) {
            tg.expand(); // Full screen
            tg.ready();
        }
    }, []);

    const userId = tg?.initDataUnsafe?.user?.id || 12345; // Fallback for browser testing
    const userName = tg?.initDataUnsafe?.user?.first_name || "Guest";

    // Polling for new numbers called by the host
    useEffect(() => {
        if (!roomId || gameWon) return;

        const interval = setInterval(async () => {
            try {
                const roomData = await getRoom(roomId);
                const numbers = roomData.calledNumbers.map(n => n.number);

                if (numbers.length !== drawnNumbers.length) {
                    setDrawnNumbers(numbers);
                    setCurrentNumber(numbers[numbers.length - 1]);
                }
            } catch (err) {
                console.error("Polling error", err);
            }
        }, 2000);

        return () => clearInterval(interval);
    }, [roomId, drawnNumbers.length, gameWon]);

    const handleStart = async () => {
        setLoading(true);
        try {
            // 1. Create the Room
            const room = await createRoom(`${userName}'s Game`, userId);
            console.log("Room Created:", room);

            if (!room || !room.roomId) {
                throw new Error("Room creation failed - no ID returned");
            }

            // 2. Set the ID immediately
            setRoomId(room.roomId);

            // 3. Join the Room using the ID from the response (not the state yet)
            const joinData = await joinRoom(room.roomId, userId);
            console.log("Joined Room:", joinData);

            // 4. Fetch the room/card data
            const roomData = await getRoom(room.roomId);
            // ... set your board here ...

        } catch (err) {
            console.error("Game Start Error:", err);
            alert(err instanceof Error ? err.message : "Failed to connect to server");
        } finally {
            setLoading(false);
        }
    };

    const onDraw = async () => {
        if (!roomId) return;
        await drawNumber(roomId);
    };

    const handleCellClick = (r: number, c: number) => {
        if (gameWon) return;
        const newBoard = [...board];
        const cell = newBoard[r][c];

        // Logic: Only allow marking if number was actually drawn (strict bingo)
        if (cell.value === 'FREE' || drawnNumbers.includes(cell.value)) {
            cell.marked = !cell.marked;
            setBoard(newBoard);

            if (checkWin(newBoard)) {
                setGameWon(true);
                confetti({ particleCount: 150, spread: 60 });
                tg.HapticFeedback.notificationOccurred('success');
            } else {
                tg.HapticFeedback.impactOccurred('light');
            }
        }
    };

    return (
        <div className="min-h-screen bg-slate-900 text-white flex flex-col items-center p-4">
            <header className="py-4">
                <h1 className="text-4xl font-black bg-gradient-to-r from-yellow-400 to-orange-500 bg-clip-text text-transparent">
                    BINGO BOT
                </h1>
            </header>

            {!roomId ? (
                <div className="flex-1 flex flex-col items-center justify-center gap-4">
                    <p className="text-slate-400">Welcome, {userName}!</p>
                    <button
                        onClick={handleStart}
                        disabled={loading}
                        className="bg-indigo-600 px-8 py-4 rounded-2xl font-bold shadow-lg active:scale-95 transition-all"
                    >
                        {loading ? "CONNECTING..." : "START PLAYING"}
                    </button>
                </div>
            ) : (
                <div className="w-full max-w-md flex flex-col gap-6">
                    <GameStatus currentNumber={currentNumber} drawnNumbers={drawnNumbers} />

                    {board.length > 0 && (
                        <BingoBoard
                            board={board}
                            onCellClick={handleCellClick}
                            gameActive={!gameWon}
                        />
                    )}

                    <ControlPanel
                        onDraw={onDraw}
                        onReset={handleStart}
                        gameActive={true}
                        drawnCount={drawnNumbers.length}
                    />
                </div>
            )}
        </div>
    );
}

export default App;