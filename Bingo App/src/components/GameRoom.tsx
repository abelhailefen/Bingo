import { useEffect, useState, useRef } from 'react';
import * as signalR from '@microsoft/signalr';
import { getRoom, getMyCards, claimBingo } from '../services/api';
import { RoomStatus } from '../types/enums'; // Now used in logic
import type { Room } from '../types/room';

export const GameRoom = ({ roomId, userId, onLeave }: { roomId: number, userId: number, onLeave: () => void }) => {
    const [cards, setCards] = useState<any[]>([]);
    const [roomData, setRoomData] = useState<Room | null>(null);
    const [drawnNumbers, setDrawnNumbers] = useState<number[]>([]);
    const [currentNumber, setCurrentNumber] = useState<{ letter: string, val: number } | null>(null);

    // Timer States (Now correctly integrated)
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

    useEffect(() => {
        const initGame = async () => {
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

                if (cardRes.data) setCards(cardRes.data);

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
            } catch (err) { console.error(err); }
        };

        initGame();
        return () => { connectionRef.current?.stop(); };
    }, [roomId, userId]);

    // Timer logic to satisfy unused variable errors and add functionality
    useEffect(() => {
        if (!roomData?.scheduledStartTime) return;
        const interval = setInterval(() => {
            const now = new Date().getTime();
            const start = new Date(roomData.scheduledStartTime).getTime();

            if (roomData.status === RoomStatus.Waiting && now < start) {
                const diff = Math.max(0, Math.floor((start - now) / 1000));
                setTimerSeconds(diff);
                setIsCountingUp(false);
            } else {
                setIsCountingUp(true);
                setTimerSeconds(prev => prev + 1);
            }
        }, 1000);
        return () => clearInterval(interval);
    }, [roomData]);

    const formatBackendCard = (numbers: any[]) => {
        if (!numbers) return Array(5).fill(null).map(() => Array(5).fill(null));
        const grid = Array(5).fill(null).map(() => Array(5).fill(null));
        numbers.forEach(n => {
            const r = (n.positionRow ?? n.PositionRow) - 1;
            const c = (n.positionCol ?? n.PositionCol) - 1;
            if (r >= 0 && r < 5 && c >= 0 && c < 5) grid[r][c] = n;
        });
        return grid;
    };

    const handleClaimBingo = async () => {
        const res = await claimBingo(roomId, userId);
        if (res.isFailed) alert(res.message);
        else alert("BINGO CLAIMED! Checking...");
    };

    return (
        <div className="flex flex-col h-screen bg-[#0f172a] text-white overflow-hidden">
            {/* 1. Header Stats - Variables now used here */}
            <div className="bg-[#1e293b] p-2 grid grid-cols-5 text-center text-[10px] font-bold border-b border-white/10 shrink-0 uppercase">
                <div className="flex flex-col"><span>Game ID</span><span className="text-indigo-400">{roomData?.roomId || roomId}</span></div>
                <div className="flex flex-col border-l border-white/10">
                    <span>{isCountingUp ? 'Duration' : 'Starts In'}</span>
                    <span className="text-indigo-400">{formatTime(timerSeconds)}</span>
                </div>
                <div className="flex flex-col border-l border-white/10"><span>Players</span><span className="text-indigo-400">84</span></div>
                <div className="flex flex-col border-l border-white/10"><span>Bet</span><span className="text-indigo-400">10</span></div>
                <div className="flex flex-col border-l border-white/10"><span>Call</span><span className="text-indigo-400">{drawnNumbers.length}</span></div>
            </div>

            <div className="flex flex-1 overflow-hidden">
                {/* 2. Left Sidebar */}
                <div className="w-24 md:w-32 bg-[#1e1b4b] border-r border-indigo-500/20 flex flex-col h-full shrink-0">
                    <div className="grid grid-cols-5 p-1 text-center font-black text-[10px] text-indigo-300 bg-black/20">
                        {['B', 'I', 'N', 'G', 'O'].map(l => <div key={l}>{l}</div>)}
                    </div>
                    <div className="flex-1 overflow-y-auto p-1 grid grid-cols-5 gap-0.5">
                        {Array.from({ length: 15 }).map((_, rowIndex) => (
                            [0, 15, 30, 45, 60].map(offset => {
                                const num = rowIndex + 1 + offset;
                                const isDrawn = drawnNumbers.includes(num);
                                return (
                                    <div key={num} className={`aspect-square flex items-center justify-center rounded-sm text-[9px] font-bold border ${isDrawn ? 'bg-green-600 border-green-400' : 'bg-white/5 border-white/5 text-slate-500'
                                        }`}>
                                        {num}
                                    </div>
                                );
                            })
                        ))}
                    </div>
                </div>

                {/* 3. Main Gameplay Area */}
                <div className="flex-1 flex flex-col overflow-y-auto bg-[#020617] p-3 space-y-4">
                    <div className="flex justify-between items-center bg-[#1e1b4b] px-4 py-2 rounded-lg border border-indigo-500/20">
                        <span className="italic font-bold text-indigo-400 tracking-widest">
                            {roomData?.status === RoomStatus.Waiting ? 'waiting' : 'playing'}
                        </span>
                        <span className="text-[10px] font-bold">🔊 Voice</span>
                    </div>

                    <div className="bg-[#1e293b] rounded-xl p-4 flex items-center justify-between border border-indigo-500/20 shadow-xl">
                        <span className="text-indigo-200 font-black uppercase tracking-widest">Current Call</span>
                        <div className="bg-[#0f172a] h-14 w-28 rounded-full flex items-center justify-center border-2 border-indigo-500 shadow-[0_0_10px_rgba(99,102,241,0.2)]">
                            <span className="text-2xl font-black text-white">
                                {currentNumber ? `${currentNumber.letter}-${currentNumber.val}` : '--'}
                            </span>
                        </div>
                    </div>

                    <div className="flex flex-col space-y-6 pb-24">
                        {cards.map((card, idx) => {
                            const master = card.masterCard || card.MasterCard || card;
                            const numbers = master.numbers || master.Numbers;

                            return (
                                <div key={idx} className="w-full max-w-[320px] mx-auto bg-[#1e1b4b] p-2 rounded-xl shadow-2xl border border-indigo-500/30">
                                    <div className="grid grid-cols-5 gap-1 mb-1">
                                        {['B', 'I', 'N', 'G', 'O'].map((l) => (
                                            <div key={l} className="text-center font-black py-1 rounded-t-md text-xs bg-indigo-900/50 text-indigo-200">
                                                {l}
                                            </div>
                                        ))}
                                    </div>
                                    <div className="grid grid-cols-5 gap-1">
                                        {formatBackendCard(numbers).map((row, rIdx) =>
                                            row.map((cell: any, cIdx: number) => {
                                                const val = cell?.number ?? cell?.Number;
                                                const isChecked = val === null || drawnNumbers.includes(val);
                                                return (
                                                    <div key={`${rIdx}-${cIdx}`}
                                                        className={`h-11 flex items-center justify-center rounded-md text-sm font-bold transition-all shadow-inner border border-black/10 ${isChecked ? 'bg-green-600 text-white' : 'bg-slate-200 text-slate-900'
                                                            }`}>
                                                        {val ?? '★'}
                                                    </div>
                                                );
                                            })
                                        )}
                                    </div>
                                    <p className="text-center text-[9px] font-bold text-indigo-400 mt-2 uppercase tracking-tighter">
                                        Board No.{master.masterCardId || master.MasterCardId || idx}
                                    </p>
                                </div>
                            );
                        })}
                    </div>
                </div>
            </div>

            {/* 4. Action Buttons */}
            <div className="p-3 bg-[#0f172a] border-t border-white/10 space-y-3 shrink-0">
                <button
                    onClick={handleClaimBingo}
                    className="w-full py-4 rounded-xl font-black text-2xl text-white bg-orange-600 hover:bg-orange-500 shadow-[0_4px_0_rgb(154,52,18)] active:translate-y-1 active:shadow-none transition-all"
                >
                    BINGO!
                </button>
                <div className="grid grid-cols-2 gap-3">
                    <button onClick={() => window.location.reload()} className="bg-slate-700 py-3 rounded-lg font-bold text-xs uppercase">Refresh</button>
                    <button onClick={onLeave} className="bg-red-900/40 border border-red-500/50 py-3 rounded-lg font-bold text-xs uppercase">Leave</button>
                </div>
            </div>
        </div>
    );
};