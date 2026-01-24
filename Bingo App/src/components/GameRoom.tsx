import { useEffect, useState, useRef, useCallback } from 'react';
import * as signalR from '@microsoft/signalr';
import Confetti from 'react-confetti';
import { getRoom, getMyCards, claimBingo } from '../services/api';
import { RoomStatus } from '../types/enums';
import type { Room } from '../types/room';

interface GameRoomProps {
    roomId: number;
    userId: number;
    onLeave: () => void;
}

export const GameRoom = ({ roomId, userId, onLeave }: GameRoomProps) => {
    // --- SETTINGS (CODE ONLY) ---
    const isAutoMode = false; // Set to false: User must click numbers manually
    // ----------------------------

    const [cards, setCards] = useState<any[] | null>(null);
    const [roomData, setRoomData] = useState<Room | null>(null);
    const [drawnNumbers, setDrawnNumbers] = useState<number[]>([]);
    const [currentNumber, setCurrentNumber] = useState<{ letter: string, val: number } | null>(null);
    const [isRefreshing, setIsRefreshing] = useState(false);
    const [winner, setWinner] = useState<{ username: string, prize: number, type: string } | null>(null);

    // Track which numbers the user has clicked
    const [userMarks, setUserMarks] = useState<Record<number, number[]>>(() => {
        try {
            const saved = localStorage.getItem(`marks_${roomId}_${userId}`);
            return saved ? JSON.parse(saved) : {};
        } catch { return {}; }
    });

    const [timerSeconds, setTimerSeconds] = useState<number>(0);
    const [isCountingUp, setIsCountingUp] = useState<boolean>(false);
    const connectionRef = useRef<signalR.HubConnection | null>(null);

    const getCallLetter = (n: number) => {
        if (n <= 15) return 'B';
        if (n <= 30) return 'I';
        if (n <= 45) return 'N';
        if (n <= 60) return 'G';
        return 'O';
    };

    const formatTime = (totalSeconds: number) => {
        const mins = Math.floor(Math.abs(totalSeconds) / 60);
        const secs = Math.abs(totalSeconds) % 60;
        return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    };

    const updateCurrentNumber = (num: number) => {
        if (!num) return;
        setCurrentNumber({ letter: getCallLetter(num), val: num });
    };

    const initGame = useCallback(async (isRefreshCall = false) => {
        if (isRefreshCall) setIsRefreshing(true);
        try {
            const [roomRes, cardRes] = await Promise.all([
                getRoom(roomId),
                getMyCards(roomId, userId)
            ]);

            if (roomRes.data) {
                setRoomData(roomRes.data);
                const called = roomRes.data.calledNumbers?.map((n: any) => n.number) || [];
                setDrawnNumbers(called);
                if (called.length > 0) updateCurrentNumber(called[called.length - 1]);
                if (roomRes.data.status === RoomStatus.InProgress) setIsCountingUp(true);
            }

            if (cardRes.data && cardRes.data.length > 0) {
                const flattenedCards = cardRes.data.map((c: any) => ({
                    ...(c.masterCard || c.MasterCard || c),
                    userCardId: c.cardId || c.CardId
                }));
                setCards(flattenedCards);
            }

            // --- SignalR Setup ---
            if (connectionRef.current) await connectionRef.current.stop();

            const connection = new signalR.HubConnectionBuilder()
                .withUrl("/bingohub")
                .withAutomaticReconnect()
                .build();

            // Listen for numbers drawn by server
            connection.on("NumberDrawn", (rId: number, number: number) => {
                if (Number(rId) !== roomId) return;
                setDrawnNumbers(prev => prev.includes(number) ? prev : [...prev, number]);
                updateCurrentNumber(number);
            });

            // Listen for game start
            connection.on("GameStarted", (rId: number) => {
                if (Number(rId) !== roomId) return;
                setIsCountingUp(true);
                setTimerSeconds(0);
                setRoomData(prev => prev ? { ...prev, status: RoomStatus.InProgress } : null);
            });

            // Listen for Bingo Wins
            connection.on("WinClaimed", (rId: number, username: string, winType: string, prize: number) => {
                if (Number(rId) !== roomId) return;
                setWinner({ username, prize, type: winType });
                setIsCountingUp(false);
            });

            await connection.start();
            await connection.invoke("JoinRoomGroup", roomId.toString());
            connectionRef.current = connection;

        } catch (err) {
            console.error("Connection Error:", err);
        } finally {
            if (isRefreshCall) setIsRefreshing(false);
        }
    }, [roomId, userId]);

    useEffect(() => {
        initGame();
        return () => { connectionRef.current?.stop(); };
    }, [initGame]);

    useEffect(() => {
        localStorage.setItem(`marks_${roomId}_${userId}`, JSON.stringify(userMarks));
    }, [userMarks, roomId, userId]);

    useEffect(() => {
        const interval = setInterval(() => {
            if (!roomData?.scheduledStartTime) return;
            const now = new Date().getTime();
            const start = new Date(roomData.scheduledStartTime).getTime();

            if (roomData.status === RoomStatus.Waiting) {
                setTimerSeconds(Math.max(0, Math.floor((start - now) / 1000)));
                setIsCountingUp(false);
            } else if (roomData.status === RoomStatus.InProgress) {
                setIsCountingUp(true);
                setTimerSeconds(prev => prev + 1);
            }
        }, 1000);
        return () => clearInterval(interval);
    }, [roomData]);

    const formatBackendCard = (numbers: any[]) => {
        const grid = Array(5).fill(null).map(() => Array(5).fill(null));
        if (!numbers) return grid;
        numbers.forEach(n => {
            const r = (n.positionRow ?? n.PositionRow) - 1;
            const c = (n.positionCol ?? n.PositionCol) - 1;
            if (r >= 0 && r < 5 && c >= 0 && c < 5) grid[r][c] = n;
        });
        return grid;
    };

    const toggleMark = (cardIdx: number, num: number | null) => {
        if (num === null || !!winner) return; // Disable clicking if game is over
        setUserMarks(prev => {
            const marks = prev[cardIdx] || [];
            const newMarks = marks.includes(num) ? marks.filter(n => n !== num) : [...marks, num];
            return { ...prev, [cardIdx]: newMarks };
        });
    };

    const handleClaimBingo = async () => {
        try {
            const res = await claimBingo(roomId, userId);
            if (res.isFailed) alert(res.message);
        } catch (e) {
            alert("Connection error while claiming Bingo.");
        }
    };

    return (
        <div className="flex flex-col h-screen bg-[#0f172a] text-white overflow-hidden relative">
            {winner && <Confetti recycle={false} numberOfPieces={400} />}

            {/* Winner Modal Overlay */}
            {winner && (
                <div className="absolute inset-0 z-[100] flex items-center justify-center p-6 bg-black/80 backdrop-blur-md">
                    <div className="bg-indigo-950 border-2 border-orange-500 rounded-3xl p-8 w-full max-w-sm text-center shadow-2xl scale-in-center">
                        <div className="text-6xl mb-4">🏆</div>
                        <h2 className="text-4xl font-black text-white mb-2 italic">BINGO!</h2>
                        <p className="text-orange-400 font-bold text-xl mb-6">{winner.username} WON</p>
                        <div className="bg-white/10 rounded-2xl p-4 mb-6">
                            <p className="text-slate-400 text-xs uppercase font-bold">Prize Pool</p>
                            <p className="text-3xl font-black text-green-400">{winner.prize} ETB</p>
                        </div>
                        <button onClick={onLeave} className="w-full py-4 bg-orange-600 hover:bg-orange-500 text-white font-black rounded-xl">
                            BACK TO LOBBY
                        </button>
                    </div>
                </div>
            )}

            {/* Header Stats */}
            <div className="bg-[#1e293b] p-2 grid grid-cols-5 text-center text-[10px] font-bold border-b border-white/10 shrink-0 uppercase">
                <div className="flex flex-col"><span>Room</span><span className="text-indigo-400">#{roomId}</span></div>
                <div className="flex flex-col border-l border-white/10">
                    <span>{isCountingUp ? 'Duration' : 'Starts'}</span>
                    <span className="text-indigo-400">{formatTime(timerSeconds)}</span>
                </div>
                <div className="flex flex-col border-l border-white/10"><span>Status</span><span className="text-indigo-400">{roomData?.status === RoomStatus.InProgress ? 'LIVE' : 'WAIT'}</span></div>
                <div className="flex flex-col border-l border-white/10"><span>Stake</span><span className="text-indigo-400">{roomData?.cardPrice}</span></div>
                <div className="flex flex-col border-l border-white/10"><span>Calls</span><span className="text-indigo-400">{drawnNumbers.length}</span></div>
            </div>

            <div className="flex flex-1 overflow-hidden">
                {/* Sidebar Call History */}
                <div className="w-32 md:w-44 bg-[#1e1b4b] border-r border-indigo-500/20 flex flex-col h-full shrink-0">
                    <div className="grid grid-cols-5 p-1 text-center font-black text-[10px] text-indigo-300 bg-black/20">
                        {['B', 'I', 'N', 'G', 'O'].map(l => <div key={l}>{l}</div>)}
                    </div>
                    <div className="flex-1 overflow-y-auto p-1 grid grid-cols-5 gap-1">
                        {[0, 15, 30, 45, 60].map((offset) => (
                            <div key={offset} className="flex flex-col gap-1">
                                {Array.from({ length: 15 }).map((_, i) => {
                                    const num = i + 1 + offset;
                                    const isDrawn = drawnNumbers.includes(num);
                                    const isLast = currentNumber?.val === num;
                                    return (
                                        <div key={num} className={`aspect-square flex items-center justify-center rounded-sm text-[9px] font-bold border transition-all ${isDrawn ? (isLast ? 'bg-orange-500 border-white animate-pulse' : 'bg-green-600 border-green-400 text-white')
                                                : 'bg-white/5 border-white/5 text-slate-600'
                                            }`}>
                                            {num}
                                        </div>
                                    );
                                })}
                            </div>
                        ))}
                    </div>
                </div>

                {/* Main Game Area */}
                <div className="flex-1 flex flex-col overflow-y-auto bg-[#020617] p-3 space-y-4">
                    {/* Big Number Display */}
                    <div className="bg-[#1e293b] rounded-xl p-4 flex items-center justify-between border border-indigo-500/20 shadow-xl">
                        <div className="flex flex-col">
                            <span className="text-indigo-200 font-black uppercase text-xs tracking-widest">Current Call</span>
                            <span className="text-[10px] text-slate-500">#{drawnNumbers.length} / 75</span>
                        </div>
                        <div className={`h-16 w-32 rounded-full flex items-center justify-center border-2 transition-all duration-500 ${currentNumber ? 'bg-orange-600 border-white' : 'bg-[#0f172a] border-indigo-500'}`}>
                            <span className="text-3xl font-black text-white">
                                {currentNumber ? `${currentNumber.letter}-${currentNumber.val}` : '--'}
                            </span>
                        </div>
                    </div>

                    {/* Cards Container */}
                    <div className="flex flex-col space-y-8 pb-32">
                        {cards ? cards.map((card, idx) => (
                            <div key={idx} className="w-full max-w-[300px] mx-auto bg-[#fefce8] p-2 rounded-xl shadow-2xl border-b-8 border-black/10">
                                <div className="grid grid-cols-5 text-center font-black text-sm mb-2">
                                    <span className="text-orange-600">B</span><span className="text-green-600">I</span>
                                    <span className="text-blue-600">N</span><span className="text-red-600">G</span>
                                    <span className="text-purple-600">O</span>
                                </div>
                                <div className="grid grid-cols-5 gap-1">
                                    {formatBackendCard(card.numbers || card.Numbers).map((row, rIdx) =>
                                        row.map((cell: any, cIdx: number) => {
                                            const val = cell?.number ?? cell?.Number;
                                            const isCalled = val === null || drawnNumbers.includes(val);
                                            const isMarked = userMarks[idx]?.includes(val);

                                            // STYLE LOGIC
                                            let cellBg = "bg-white text-slate-800";
                                            if (isAutoMode) {
                                                if (isCalled) cellBg = "bg-green-500 text-white";
                                            } else {
                                                if (val === null) cellBg = "bg-green-500 text-white";
                                                else if (isMarked && isCalled) cellBg = "bg-green-500 text-white";
                                                else if (isMarked && !isCalled) cellBg = "bg-orange-400 text-white";
                                            }

                                            return (
                                                <div key={`${rIdx}-${cIdx}`}
                                                    onClick={() => toggleMark(idx, val)}
                                                    className={`h-11 flex items-center justify-center rounded-sm text-base font-black transition-all border border-black/5 select-none relative cursor-pointer active:scale-90 ${cellBg}`}>
                                                    {val ?? '★'}

                                                    {/* Hint for Manual Mode: Small green dot if called but not clicked */}
                                                    {!isAutoMode && val !== null && isCalled && !isMarked && (
                                                        <div className="absolute top-1 right-1 w-2 h-2 bg-green-500 rounded-full animate-ping" />
                                                    )}
                                                </div>
                                            );
                                        })
                                    )}
                                </div>
                                <p className="text-center text-[10px] font-bold text-slate-400 mt-2 uppercase">Ticket ID: {card.userCardId}</p>
                            </div>
                        )) : (
                            <div className="text-center text-slate-500 py-20 italic">Loading your boards...</div>
                        )}
                    </div>
                </div>
            </div>

            {/* Bottom Actions */}
            <div className="p-3 bg-[#0f172a] border-t border-white/10 space-y-3 shrink-0 z-50">
                <button
                    onClick={handleClaimBingo}
                    disabled={roomData?.status !== RoomStatus.InProgress || !!winner}
                    className="w-full py-5 rounded-2xl font-black text-3xl text-white bg-orange-600 hover:bg-orange-500 shadow-[0_6px_0_rgb(154,52,18)] active:translate-y-1 active:shadow-none transition-all disabled:opacity-50 disabled:grayscale"
                >
                    {winner ? 'GAME ENDED' : 'BINGO!'}
                </button>
                <div className="grid grid-cols-2 gap-3">
                    <button
                        onClick={() => initGame(true)}
                        disabled={isRefreshing || !!winner}
                        className="bg-slate-800 py-3 rounded-xl font-bold text-xs uppercase text-slate-300"
                    >
                        {isRefreshing ? 'Syncing...' : 'Sync Data'}
                    </button>
                    <button onClick={onLeave} className="bg-red-950/30 border border-red-500/30 py-3 rounded-xl font-bold text-xs uppercase text-red-500">
                        Leave Room
                    </button>
                </div>
            </div>
        </div>
    );
};