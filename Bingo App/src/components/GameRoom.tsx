import { useEffect, useState, useRef, useCallback } from 'react';
import { useDispatch } from 'react-redux';
import * as signalR from '@microsoft/signalr';
import Confetti from 'react-confetti';
import { getRoom, getMyCards, claimBingo } from '../services/api';
import { resetLobby } from '../store/gameSlice';
import { RoomStatus } from '../types/enums';
import type { Room } from '../types/room';

interface GameRoomProps {
    roomId: number;
    userId: number;
    onLeave: () => void;
}

export const GameRoom = ({ roomId, userId, onLeave }: GameRoomProps) => {
    const dispatch = useDispatch();

    // --- STATE ---
    const [isAutoMode, setIsAutoMode] = useState(() => localStorage.getItem(`autoMode_${userId}`) === 'true');
    const [cards, setCards] = useState<any[] | null>(null);
    const [roomData, setRoomData] = useState<Room | null>(null);
    const [drawnNumbers, setDrawnNumbers] = useState<number[]>([]);
    const [currentNumber, setCurrentNumber] = useState<{ letter: string, val: number } | null>(null);
    const [isRefreshing, setIsRefreshing] = useState(false);
    const [winner, setWinner] = useState<{ username: string, prize: number, type: string } | null>(null);
    const [gameOverMessage, setGameOverMessage] = useState<string | null>(null);
    const [timerSeconds, setTimerSeconds] = useState<number>(0);
    const [isCountingUp, setIsCountingUp] = useState<boolean>(false);

    const connectionRef = useRef<signalR.HubConnection | null>(null);

    const [userMarks, setUserMarks] = useState<Record<number, number[]>>(() => {
        try {
            const saved = localStorage.getItem(`marks_${roomId}_${userId}`);
            return saved ? JSON.parse(saved) : {};
        } catch { return {}; }
    });

    const getCallLetter = (n: number) => {
        if (n <= 15) return 'B';
        if (n <= 30) return 'I';
        if (n <= 45) return 'N';
        if (n <= 60) return 'G';
        return 'O';
    };

    const updateCurrentNumber = useCallback((num: number) => {
        if (!num) return;
        setCurrentNumber({ letter: getCallLetter(num), val: num });
    }, []);

    const formatTime = (s: number) => {
        const mins = Math.floor(s / 60);
        const secs = s % 60;
        return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
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

            if (cardRes.data) {
                const normalized = cardRes.data.map((c: any) => ({
                    ...(c.masterCard || c.MasterCard || c),
                    userCardId: c.cardId || c.CardId || c.id
                }));
                setCards(normalized);
            }

            if (connectionRef.current) await connectionRef.current.stop();
            const connection = new signalR.HubConnectionBuilder()
                .withUrl("/bingohub")
                .withAutomaticReconnect()
                .build();

            connection.on("GameStarted", (rId) => {
                if (Number(rId) === roomId) {
                    setIsCountingUp(true);
                    setRoomData(prev => prev ? { ...prev, status: RoomStatus.InProgress } : null);
                }
            });

            connection.on("NumberDrawn", (rId, number) => {
                if (Number(rId) !== roomId) return;
                setIsCountingUp(true);
                setDrawnNumbers(prev => prev.includes(number) ? prev : [...prev, number]);
                updateCurrentNumber(number);
            });

            connection.on("WinClaimed", (rId, username, winType, prize) => {
                if (Number(rId) !== roomId) return;
                setWinner({ username, prize, type: winType });
                setIsCountingUp(false);
            });

            connection.on("GameEnded", (rId, message) => {
                if (Number(rId) !== roomId) return;
                setGameOverMessage(message);
                setIsCountingUp(false);
            });

            await connection.start();
            await connection.invoke("JoinRoomGroup", roomId.toString());
            connectionRef.current = connection;
        } catch (err) {
            console.error(err);
        } finally {
            if (isRefreshCall) setIsRefreshing(false);
        }
    }, [roomId, userId, updateCurrentNumber]);

    useEffect(() => {
        initGame();
        return () => {
            connectionRef.current?.stop();
            dispatch(resetLobby());
        };
    }, [initGame, dispatch]);

    useEffect(() => {
        const interval = setInterval(() => {
            if (!roomData?.scheduledStartTime) return;
            const now = new Date().getTime();
            const start = new Date(roomData.scheduledStartTime).getTime();
            if (roomData.status === RoomStatus.Waiting) {
                setTimerSeconds(Math.max(0, Math.floor((start - now) / 1000)));
            } else if (roomData.status === RoomStatus.InProgress && !winner && !gameOverMessage) {
                setTimerSeconds(prev => prev + 1);
            }
        }, 1000);
        return () => clearInterval(interval);
    }, [roomData, winner, gameOverMessage]);

    useEffect(() => {
        localStorage.setItem(`marks_${roomId}_${userId}`, JSON.stringify(userMarks));
        localStorage.setItem(`autoMode_${userId}`, String(isAutoMode));
    }, [userMarks, isAutoMode, roomId, userId]);

    useEffect(() => {
        if (isAutoMode && cards) {
            const newMarks: Record<number, number[]> = {};
            cards.forEach((card, idx) => {
                const cardNums = (card.numbers || card.Numbers || []).map((n: any) => n.number ?? n.Number);
                newMarks[idx] = cardNums.filter((n: number) => drawnNumbers.includes(n) || n === null);
            });
            setUserMarks(newMarks);
        }
    }, [isAutoMode, drawnNumbers, cards]);

    const toggleMark = (num: number | null, cardIdx: number) => {
        if (num === null || winner || gameOverMessage || isAutoMode) return;
        setUserMarks(prev => {
            const current = prev[cardIdx] || [];
            const next = current.includes(num) ? current.filter(n => n !== num) : [...current, num];
            return { ...prev, [cardIdx]: next };
        });
    };

    const handleClaimBingo = async () => {
        try {
            const res = await claimBingo(roomId, userId);
            if (res.isFailed) alert(res.message);
        } catch (e) {
            alert("Server error.");
        }
    };

    const canClaimBingo = (roomData?.status === RoomStatus.InProgress || isCountingUp) && !winner && !gameOverMessage;

    return (
        <div className="flex flex-col h-screen bg-[#0f172a] text-white overflow-hidden relative">
            {winner && <Confetti recycle={false} numberOfPieces={400} />}

            {/* WINNER MODAL */}
            {winner && (
                <div className="absolute inset-0 z-[100] flex items-center justify-center p-6 bg-black/80 backdrop-blur-md">
                    <div className="bg-indigo-950 border-2 border-orange-500 rounded-3xl p-8 w-full max-w-sm text-center shadow-2xl">
                        <div className="text-6xl mb-4">🏆</div>
                        <h2 className="text-4xl font-black mb-2 italic text-white">BINGO!</h2>
                        <p className="text-orange-400 font-bold text-xl mb-6">{winner.username.toUpperCase()} WON</p>
                        <div className="bg-white/10 rounded-2xl p-4 mb-6">
                            <p className="text-slate-400 text-xs uppercase font-bold">Prize Pool</p>
                            <p className="text-3xl font-black text-green-400">{winner.prize} ETB</p>
                        </div>
                        <button onClick={onLeave} className="w-full py-4 bg-orange-600 hover:bg-orange-500 text-white font-black rounded-xl">PLAY AGAIN</button>
                    </div>
                </div>
            )}

            {/* GAME OVER MODAL (No Winner) */}
            {gameOverMessage && !winner && (
                <div className="absolute inset-0 z-[100] flex items-center justify-center p-6 bg-black/80 backdrop-blur-md">
                    <div className="bg-slate-900 border-2 border-red-500 rounded-3xl p-8 w-full max-w-sm text-center shadow-2xl">
                        <div className="text-6xl mb-4">⌛</div>
                        <h2 className="text-4xl font-black mb-2 italic text-white">GAME OVER</h2>
                        <p className="text-red-400 font-bold text-lg mb-6 uppercase tracking-wider">{gameOverMessage}</p>
                        <button onClick={onLeave} className="w-full py-4 bg-slate-700 hover:bg-slate-600 text-white font-black rounded-xl">BACK TO WAGERS</button>
                    </div>
                </div>
            )}

            {/* TOP BAR */}
            <div className="bg-[#1e293b] p-2 grid grid-cols-4 text-center text-[10px] font-bold border-b border-white/10 shrink-0 uppercase tracking-tighter">
                <div className="flex flex-col"><span>Room</span><span className="text-indigo-400">#{roomId}</span></div>
                <div className="flex flex-col border-l border-white/10"><span>Status</span><span className="text-indigo-400">{roomData?.status === RoomStatus.InProgress ? 'LIVE' : 'WAITING'}</span></div>
                <div className="flex flex-col border-l border-white/10"><span>Stake</span><span className="text-indigo-400">{roomData?.cardPrice} ETB</span></div>
                <div className="flex flex-col border-l border-white/10"><span>Calls</span><span className="text-indigo-400">{drawnNumbers.length}</span></div>
            </div>

            <div className="flex flex-1 overflow-hidden">
                {/* WIDER SIDEBAR GRID */}
                <div className="w-32 md:w-52 bg-[#1e1b4b] border-r border-indigo-500/20 flex flex-col h-full shrink-0">
                    <div className="grid grid-cols-5 p-2 text-center font-black text-xs text-indigo-300 bg-black/30">
                        {['B', 'I', 'N', 'G', 'O'].map(l => <div key={l}>{l}</div>)}
                    </div>
                    <div className="flex-1 overflow-y-auto p-2 grid grid-cols-5 gap-1.5 content-start">
                        {Array.from({ length: 75 }).map((_, i) => {
                            // Calculate row and column based on grid index 'i' (0-74)
                            const row = Math.floor(i / 5); // 0 to 14
                            const col = i % 5;             // 0 to 4

        
                            const num = (col * 15) + (row + 1);

                            const isDrawn = drawnNumbers.includes(num);
                            const isLast = currentNumber?.val === num;

                            return (
                                <div
                                    key={num}
                                    className={`aspect-square flex items-center justify-center rounded-md text-[10px] md:text-xs font-bold border transition-all 
                        ${isDrawn
                                            ? (isLast ? 'bg-orange-500 border-white animate-pulse scale-110 z-10' : 'bg-green-600 border-green-400 text-white')
                                            : 'bg-white/5 border-transparent text-slate-700'
                                        }`}
                                >
                                    {num}
                                </div>
                            );
                        })}
                    </div>
                </div>

                {/* MAIN CONTENT */}
                <div className="flex-1 flex flex-col overflow-y-auto bg-[#020617] p-3 space-y-4">
                    <div className="bg-[#1e293b] rounded-xl p-4 flex items-center justify-between border border-indigo-500/20 shadow-xl shrink-0">
                        <div className="flex flex-col">
                            <span className="text-indigo-200 font-black uppercase text-[10px] tracking-widest">{isCountingUp ? 'Duration' : 'Starts In'}</span>
                            <span className="text-xl font-mono font-bold text-indigo-400">{formatTime(timerSeconds)}</span>
                        </div>
                        <div className={`h-16 w-32 rounded-full flex items-center justify-center border-2 transition-all duration-500 ${currentNumber ? 'bg-orange-600 border-white shadow-[0_0_20px_rgba(234,88,12,0.4)]' : 'bg-[#0f172a] border-indigo-500'}`}>
                            <span className="text-3xl font-black text-white">{currentNumber ? `${currentNumber.letter}-${currentNumber.val}` : '--'}</span>
                        </div>
                    </div>

                    <div className="flex flex-col space-y-8 pb-32">
                        {cards ? cards.map((card, idx) => (
                            <div key={idx} className="w-full max-w-[320px] mx-auto bg-[#fefce8] p-3 rounded-xl shadow-2xl border-b-8 border-black/10">
                                <div className="grid grid-cols-5 text-center font-black text-lg mb-2">
                                    <span className="text-orange-600">B</span><span className="text-green-600">I</span><span className="text-blue-600">N</span><span className="text-red-600">G</span><span className="text-purple-600">O</span>
                                </div>
                                <div className="grid grid-cols-5 gap-1">
                                    {Array(5).fill(0).map((_, r) => (
                                        Array(5).fill(0).map((_, c) => {
                                            const cardNums = card.numbers || card.Numbers || [];
                                            const cell = cardNums.find((n: any) => (n.positionRow ?? n.PositionRow) === r + 1 && (n.positionCol ?? n.PositionCol) === c + 1);
                                            const val = cell?.number ?? cell?.Number ?? null;
                                            const isCalled = val === null || drawnNumbers.includes(val);
                                            const isMarked = userMarks[idx]?.includes(val);
                                            let cellBg = "bg-white text-slate-800";
                                            if (val === null || (isMarked && isCalled)) cellBg = "bg-green-500 text-white";
                                            else if (isMarked) cellBg = "bg-orange-400 text-white";
                                            return (
                                                <div key={`${r}-${c}`} onClick={() => toggleMark(val, idx)} className={`aspect-square flex items-center justify-center rounded-md text-lg font-black transition-all border border-black/10 cursor-pointer active:scale-95 ${cellBg}`}>
                                                    {val ?? '★'}
                                                </div>
                                            );
                                        })
                                    ))}
                                </div>
                                <p className="text-center text-[10px] font-bold text-slate-400 mt-3 uppercase tracking-widest">Ticket ID: {card.userCardId}</p>
                            </div>
                        )) : <div className="text-center text-slate-500 py-20 italic">Loading boards...</div>}
                    </div>
                </div>
            </div>

            {/* BOTTOM CONTROLS */}
            <div className="p-3 bg-[#0f172a] border-t border-white/10 space-y-3 shrink-0 z-50">
                <div className="flex justify-start">
                    <button onClick={() => setIsAutoMode(!isAutoMode)} className={`flex items-center gap-3 px-4 py-2.5 rounded-xl border transition-all ${isAutoMode ? 'bg-green-950/30 border-green-500/50' : 'bg-slate-800 border-transparent'}`}>
                        <span className={`text-[10px] font-bold uppercase ${isAutoMode ? 'text-green-400' : 'text-slate-300'}`}>Auto-Mark {isAutoMode ? 'ON' : 'OFF'}</span>
                        <div className={`relative inline-flex h-4 w-8 items-center rounded-full transition-colors ${isAutoMode ? 'bg-green-600' : 'bg-slate-600'}`}>
                            <span className={`inline-block h-2 w-2 transform rounded-full bg-white transition-transform ${isAutoMode ? 'translate-x-5' : 'translate-x-1'}`} />
                        </div>
                    </button>
                </div>

                <button
                    onClick={handleClaimBingo}
                    disabled={!canClaimBingo}
                    className="w-full py-5 rounded-2xl font-black text-3xl text-white bg-orange-600 hover:bg-orange-500 shadow-[0_6px_0_rgb(154,52,18)] active:translate-y-1 transition-all disabled:opacity-50 disabled:grayscale"
                >
                    {winner || gameOverMessage ? 'GAME ENDED' : 'BINGO!'}
                </button>

                <div className="grid grid-cols-2 gap-3">
                    <button onClick={() => initGame(true)} disabled={isRefreshing} className="bg-slate-800 py-3 rounded-xl font-bold text-xs uppercase text-slate-300">
                        {isRefreshing ? 'Syncing...' : 'Sync Data'}
                    </button>
                    <button onClick={onLeave} className="bg-red-950/30 border border-red-500/30 py-3 rounded-xl font-bold text-xs uppercase text-red-500">Back to Wagers</button>
                </div>
            </div>
        </div>
    );
};