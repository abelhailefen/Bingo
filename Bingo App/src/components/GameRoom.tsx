import { useEffect, useState, useRef, useCallback } from 'react';
import * as signalR from '@microsoft/signalr';
import { getRoom, getMyCards, claimBingo } from '../services/api';
import { RoomStatus } from '../types/enums';
import type { Room } from '../types/room';

export const GameRoom = ({ roomId, userId, onLeave }: { roomId: number, userId: number, onLeave: () => void }) => {
    // Initialize with null to distinguish between "not loaded" and "empty"
    const [cards, setCards] = useState<any[] | null>(null);
    const [roomData, setRoomData] = useState<Room | null>(null);
    const [drawnNumbers, setDrawnNumbers] = useState<number[]>([]);
    const [currentNumber, setCurrentNumber] = useState<{ letter: string, val: number } | null>(null);
    const [isRefreshing, setIsRefreshing] = useState(false);

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
            }

            if (cardRes.data && cardRes.data.length > 0) {
                const flattenedCards = cardRes.data.map((c: any) => ({
                    ...(c.masterCard || c.MasterCard || c),
                    userCardId: c.cardId || c.CardId
                }));
                setCards(flattenedCards);
            }

            if (connectionRef.current) await connectionRef.current.stop();
            const connection = new signalR.HubConnectionBuilder()
                .withUrl("/bingohub")
                .withAutomaticReconnect()
                .build();

            connection.on("NewNumberCalled", (number: number) => {
                setDrawnNumbers(prev => [...prev, number]);
                updateCurrentNumber(number);
            });

            connection.on("GameStarted", () => {
                setIsCountingUp(true);
                setTimerSeconds(0);
            });

            await connection.start();
            await connection.invoke("JoinRoomGroup", roomId.toString());
            connectionRef.current = connection;
        } catch (err) {
            console.error("Game Init Error:", err);
        } finally {
            if (isRefreshCall) setIsRefreshing(false);
        }
    }, [roomId, userId]);

    // Only run on mount or when ID changes
    useEffect(() => {
        initGame();
        return () => { connectionRef.current?.stop(); };
    }, [roomId, userId]); // Removed initGame from deps to prevent unnecessary cycles

    useEffect(() => {
        localStorage.setItem(`marks_${roomId}_${userId}`, JSON.stringify(userMarks));
    }, [userMarks, roomId, userId]);

    useEffect(() => {
        if (!roomData?.scheduledStartTime) return;
        const interval = setInterval(() => {
            const now = new Date().getTime();
            const start = new Date(roomData.scheduledStartTime).getTime();

            if (roomData.status === RoomStatus.Waiting && now < start) {
                setTimerSeconds(Math.max(0, Math.floor((start - now) / 1000)));
                setIsCountingUp(false);
            } else {
                setIsCountingUp(true);
                setTimerSeconds(prev => prev + 1);
            }
        }, 1000);
        return () => clearInterval(interval);
    }, [roomData?.status, roomData?.scheduledStartTime]);

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
        if (num === null) return;
        setUserMarks(prev => {
            const marks = prev[cardIdx] || [];
            const newMarks = marks.includes(num) ? marks.filter(n => n !== num) : [...marks, num];
            return { ...prev, [cardIdx]: newMarks };
        });
    };

    const handleClaimBingo = async () => {
        const res = await claimBingo(roomId, userId);
        if (res.isFailed) alert(res.message);
        else alert("BINGO CLAIMED! Checking...");
    };

    const handleLeave = () => {
        localStorage.removeItem(`marks_${roomId}_${userId}`);
        onLeave();
    };

    return (
        <div className="flex flex-col h-screen bg-[#0f172a] text-white overflow-hidden">
            {/* 1. Header Stats */}
            <div className="bg-[#1e293b] p-2 grid grid-cols-5 text-center text-[10px] font-bold border-b border-white/10 shrink-0 uppercase">
                <div className="flex flex-col"><span>Game ID</span><span className="text-indigo-400">{roomId}</span></div>
                <div className="flex flex-col border-l border-white/10">
                    <span>{isCountingUp ? 'Duration' : 'Starts In'}</span>
                    <span className="text-indigo-400">{formatTime(timerSeconds)}</span>
                </div>
                <div className="flex flex-col border-l border-white/10"><span>Players</span><span className="text-indigo-400">84</span></div>
                <div className="flex flex-col border-l border-white/10"><span>Bet</span><span className="text-indigo-400">10</span></div>
                <div className="flex flex-col border-l border-white/10"><span>Call</span><span className="text-indigo-400">{drawnNumbers.length}</span></div>
            </div>

            <div className="flex flex-1 overflow-hidden">
                {/* 2. Left Sidebar (Wide Grid) */}
                <div className="w-36 md:w-44 bg-[#1e1b4b] border-r border-indigo-500/20 flex flex-col h-full shrink-0">
                    <div className="grid grid-cols-5 p-1 text-center font-black text-[10px] text-indigo-300 bg-black/20 uppercase">
                        {['B', 'I', 'N', 'G', 'O'].map(l => <div key={l}>{l}</div>)}
                    </div>
                    <div className="flex-1 overflow-y-auto p-1.5 grid grid-cols-5 gap-1">
                        {Array.from({ length: 15 }).map((_, rowIndex) => (
                            [0, 15, 30, 45, 60].map(offset => {
                                const num = rowIndex + 1 + offset;
                                const isDrawn = drawnNumbers.includes(num);
                                return (
                                    <div key={num} className={`aspect-square flex items-center justify-center rounded-md text-[10px] font-bold border ${isDrawn ? 'bg-green-600 border-green-400 shadow-sm' : 'bg-white/5 border-white/5 text-slate-500'
                                        }`}>
                                        {num}
                                    </div>
                                );
                            })
                        ))}
                    </div>
                </div>

                {/* 3. Main Content Area */}
                <div className="flex-1 flex flex-col overflow-y-auto bg-[#020617] p-3 space-y-4">
                    <div className="flex justify-between items-center bg-[#1e1b4b] px-4 py-2 rounded-lg border border-indigo-500/20">
                        <span className="italic font-bold text-indigo-400 tracking-widest uppercase text-xs">
                            {roomData?.status === RoomStatus.Waiting ? 'waiting' : 'playing'}
                        </span>
                        <span className="text-[10px] font-bold">🔊 Voice</span>
                    </div>

                    <div className="bg-[#1e293b] rounded-xl p-4 flex items-center justify-between border border-indigo-500/20 shadow-xl">
                        <span className="text-indigo-200 font-black uppercase tracking-widest text-sm">Current Call</span>
                        <div className="bg-[#0f172a] h-14 w-28 rounded-full flex items-center justify-center border-2 border-indigo-500">
                            <span className="text-2xl font-black text-white">
                                {currentNumber ? `${currentNumber.letter}-${currentNumber.val}` : '--'}
                            </span>
                        </div>
                    </div>

                    {/* Cards Logic: Shows cards if present, otherwise shows loading */}
                    <div className="flex flex-col space-y-6 pb-24">
                        {cards ? (
                            cards.map((card, idx) => (
                                <div key={idx} className="w-full max-w-[280px] mx-auto bg-[#1e1b4b] p-2 rounded-xl shadow-2xl border border-indigo-500/30">
                                    <div className="grid grid-cols-5 gap-1 mb-1">
                                        {['B', 'I', 'N', 'G', 'O'].map((l) => (
                                            <div key={l} className="text-center font-black py-1 rounded-t-md text-xs bg-indigo-900/50 text-indigo-200">{l}</div>
                                        ))}
                                    </div>
                                    <div className="grid grid-cols-5 gap-1">
                                        {formatBackendCard(card.numbers || card.Numbers).map((row, rIdx) =>
                                            row.map((cell: any, cIdx: number) => {
                                                const val = cell?.number ?? cell?.Number;
                                                const isChecked = val === null || drawnNumbers.includes(val) || userMarks[idx]?.includes(val);
                                                return (
                                                    <div
                                                        key={`${rIdx}-${cIdx}`}
                                                        onClick={() => toggleMark(idx, val)}
                                                        className={`h-9 flex items-center justify-center rounded-md text-sm font-bold transition-all cursor-pointer border border-black/10 select-none ${isChecked ? 'bg-green-600 text-white scale-95' : 'bg-slate-200 text-slate-900 active:bg-slate-300'
                                                            }`}>
                                                        {val ?? '★'}
                                                    </div>
                                                );
                                            })
                                        )}
                                    </div>
                                    <p className="text-center text-[9px] font-bold text-indigo-400 mt-2 uppercase">
                                        Board No.{card.masterCardId || card.MasterCardId || idx}
                                    </p>
                                </div>
                            ))
                        ) : (
                            <div className="text-center text-slate-500 py-10 italic animate-pulse">Loading cards...</div>
                        )}
                    </div>
                </div>
            </div>

            {/* 4. Footer Actions */}
            <div className="p-3 bg-[#0f172a] border-t border-white/10 space-y-3 shrink-0">
                <button
                    onClick={handleClaimBingo}
                    className="w-full py-4 rounded-xl font-black text-2xl text-white bg-orange-600 hover:bg-orange-500 shadow-[0_4px_0_rgb(154,52,18)] active:translate-y-0.5 active:shadow-none transition-all"
                >
                    BINGO!
                </button>
                <div className="grid grid-cols-2 gap-3">
                    <button
                        onClick={() => initGame(true)}
                        disabled={isRefreshing}
                        className={`bg-slate-700 py-3 rounded-lg font-bold text-xs uppercase transition-all ${isRefreshing ? 'opacity-50' : 'hover:bg-slate-600'}`}
                    >
                        {isRefreshing ? 'Refreshing...' : 'Refresh'}
                    </button>
                    <button onClick={handleLeave} className="bg-red-900/40 border border-red-500/50 py-3 rounded-lg font-bold text-xs uppercase">Leave</button>
                </div>
            </div>
        </div>
    );
};