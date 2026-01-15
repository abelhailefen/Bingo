import { useState, useEffect } from 'react';
import confetti from 'canvas-confetti';
import { BingoBoard } from './BingoBoard';
import { ControlPanel } from './ControlPanel';
import { GameStatus } from './GameStatus';
import { getRoom, drawNumber, claimWin } from '../services/api';
import { formatBackendCard, checkWin } from '../utils/gameLogic';

interface GameRoomProps {
    roomId: number;
    userId: number;
    onLeave: () => void;
}

export const GameRoom = ({ roomId, userId, onLeave }: GameRoomProps) => {
    const [board, setBoard] = useState<any[][]>([]);
    const [drawnNumbers, setDrawnNumbers] = useState<number[]>([]);
    const [currentNumber, setCurrentNumber] = useState<number | null>(null);
    const [gameWon, setGameWon] = useState(false);

    const [cardId, setCardId] = useState<number | null>(null);

    // Initial Load & Polling
    useEffect(() => {
        let interval: ReturnType<typeof setInterval>;

        const fetchRoomData = async () => {
            try {
                const response = await getRoom(roomId);
                if (response.isSuccess && response.data) {
                    const roomData = response.data;

                    // Sync Numbers
                    const numbers = roomData.calledNumbers.map((n: any) => n.number);
                    if (numbers.length !== drawnNumbers.length) {
                        setDrawnNumbers(numbers);
                        setCurrentNumber(numbers[numbers.length - 1]);
                    }

                    // Sync Card (Only once or if missing)
                    if (board.length === 0) {
                        const myCard = roomData.cards?.find((c: any) => c.userId === userId);
                        if (myCard && myCard.numbers) {
                            setCardId(myCard.cardId);
                            setBoard(formatBackendCard(myCard.numbers));
                        } else {
                            // If user just joined, card might be created? 
                            // Actually JoinRoom creates card if price is 0.
                            // If not found yet, maybe wait?
                        }
                    }
                }
            } catch (err) {
                console.error("Polling error", err);
            }
        };

        fetchRoomData(); // Initial call
        interval = setInterval(fetchRoomData, 2000); // Poll

        return () => clearInterval(interval);
    }, [roomId, userId, drawnNumbers.length]);

    const onDraw = async () => {
        try {
            await drawNumber(roomId, userId);
        } catch (err) {
            console.error("Draw error", err);
        }
    };

    const handleCellClick = async (r: number, c: number) => {
        if (gameWon) return;

        const newBoard = [...board];
        const cell = newBoard[r][c];

        const isDrawn = drawnNumbers.includes(cell.value);

        if (cell.value === 'FREE' || isDrawn) {
            cell.marked = !cell.marked;
            setBoard(newBoard);

            if (checkWin(newBoard)) {
                setGameWon(true);
                confetti({ particleCount: 150, spread: 60 });
                // Attempt Claim
                if (cardId) {
                    try {
                        await claimWin(roomId, userId, cardId, 0); // 0 = Line for now? 
                        // TODO: Handle Claim Response
                    } catch (e) {
                        console.error(e);
                    }
                }
            }
        }
    };

    return (
        <div className="w-full max-w-md flex flex-col gap-6">
            <div className="flex justify-between items-center text-slate-400 text-sm">
                <span>Room #{roomId}</span>
                <button onClick={onLeave} className="text-red-400 hover:text-red-300">Leave Game</button>
            </div>

            <GameStatus currentNumber={currentNumber} drawnNumbers={drawnNumbers} />

            {board.length > 0 ? (
                <BingoBoard
                    board={board}
                    onCellClick={handleCellClick}
                    gameActive={!gameWon}
                />
            ) : (
                <div className="text-center py-10 text-slate-500">
                    Loading Card...
                </div>
            )}

            <ControlPanel
                onDraw={onDraw}
                onReset={onLeave} // Reuse reset for leaving for now? Or separate?
                gameActive={true}
                drawnCount={drawnNumbers.length}
            />
        </div>
    );
};
