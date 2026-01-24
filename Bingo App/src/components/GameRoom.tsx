import { useEffect, useState, useRef } from 'react';
import * as signalR from '@microsoft/signalr';
import { getRoom, getMyCards, claimBingo } from '../services/api';
import { RoomStatus } from '../types/enums';
import type { Room } from '../types/room';

export const GameRoom = ({ roomId, userId, onLeave }: { roomId: number, userId: number, onLeave: () => void }) => {
    const [cards, setCards] = useState<any[]>([]);
    const [roomData, setRoomData] = useState<Room | null>(null);
    const [drawnNumbers, setDrawnNumbers] = useState<number[]>([]);
    const [currentNumber, setCurrentNumber] = useState<{ letter: string, val: number } | null>(null);

    // Timer States
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
                    const called = roomRes.data.calledNumbers.map((n: any) => n.number);
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
                    try { new Audio('/assets/pop.mp3').play(); } catch (e) { }
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
                setTimerSeconds(prev => (isCountingUp ? prev + 1 : 0));
            }
        }, 1000);
        return () => clearInterval(interval);
    }, [roomData, isCountingUp]);

    const formatBackendCard = (numbers: any[]) => {
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
        <div className="flex flex-col h-screen bg-[#0f172a] text-white overflow-hidden font-sans">
            {/* Header Stats Bar */}
            <div className="bg-[#1e293b] p-3 grid grid-cols-5 text-center gap-1 text-[11px] uppercase font-bold border-b border-white/5 shadow-lg">
                <div className="flex flex-col"><span className="text-slate-400">Game ID</span><span>{roomId}</span></div>
                <div className="flex flex-col border-l border-white/10">
                    <span className="text-orange-400">{isCountingUp ? 'Duration' : 'Starts In'}</span>
                    <span className={!isCountingUp && timerSeconds < 10 ? 'text-red-500 animate-pulse' : ''}>{formatTime(timerSeconds)}</span>
                </div>
                <div className="flex flex-col border-l border-white/10"><span className="text-slate-400">Players</span><span>84</span></div>
                <div className="flex flex-col border-l border-white/10"><span className="text-slate-400">Bet</span><span>10</span></div>
                <div className="flex flex-col border-l border-white/10"><span className="text-slate-400">Call</span><span>{drawnNumbers.length}</span></div>
            </div>

            <div className="flex flex-1 overflow-hidden">
                {/* LEFT SIDEBAR: Vertical B-I-N-G-O Grid (1-75) */}
                <div className="w-[140px] bg-[#1e1b4b] border-r border-indigo-500/30 flex flex-col h-full shrink-0">
                    <div className="grid grid-cols-5 p-2 text-center font-black text-indigo-300 border-b border-indigo-500/30">
                        {['B', 'I', 'N', 'G', 'O'].map(l => <div key={l} className="text-sm">{l}</div>)}
                    </div>
                    <div className="flex-1 overflow-y-auto p-1.5 grid grid-cols-5 gap-1 custom-scrollbar">
                        {Array.from({ length: 15 }).map((_, rowIndex) => (
                            [0, 15, 30, 45, 60].map(offset => {
                                const num = rowIndex + 1 + offset;
                                const isDrawn = drawnNumbers.includes(num);
                                return (
                                    <div key={num} className={`aspect-square flex items-center justify-center rounded-md text-[11px] font-bold transition-all shadow-sm
                                        ${isDrawn ? 'bg-green-500 text-white border border-green-400' : 'bg-white/5 text-indigo-300/40 border border-white/5'}`}>
                                        {num}
                                    </div>
                                );
                            })
                        ))}
                    </div>
                </div>

                {/* MAIN GAMEPLAY AREA */}
                <div className="flex-1 flex flex-col p-3 overflow-y-auto bg-[#020617] space-y-4">

                    {/* Status Display */}
                    <div className="bg-[#1e1b4b] rounded-xl p-2 px-4 flex justify-between items-center border border-indigo-500/20">
                        <span className="text-indigo-400 font-bold italic tracking-wider">
                            {isCountingUp ? 'playing' : 'waiting...'}
                        </span>
                        <div className="flex items-center space-x-2 text-indigo-300">
                            <span className="text-xs font-bold uppercase">🔊 Voice</span>
                        </div>
                    </div>

                    {/* Current Call Display */}
                    <div className="bg-[#1e293b] rounded-2xl p-4 flex items-center justify-between border-2 border-indigo-500/20 shadow-2xl">
                        <span className="text-indigo-200 text-lg font-bold uppercase tracking-widest">Current Call</span>
                        <div className="bg-[#0f172a] h-16 w-32 rounded-full flex items-center justify-center border-2 border-orange-500 shadow-[0_0_15px_rgba(249,115,22,0.3)]">
                            <span className="text-3xl font-black text-white">{currentNumber ? `${currentNumber.letter}-${currentNumber.val}` : '--'}</span>
                        </div>
                    </div>

                    {/* Bingo Cards Stack */}
                    <div className="flex flex-col space-y-6 pb-40">
                        {cards.map((card) => (
                            <div key={card.cardId} className="bg-[#1e1b4b] p-3 rounded-2xl shadow-2xl border border-indigo-500/30 max-w-sm mx-auto w-full">
                                {/* Card Header */}
                                <div className="grid grid-cols-5 gap-1 mb-1.5">
                                    {['B', 'I', 'N', 'G', 'O'].map((l, i) => (
                                        <div key={l} className={`text-center font-black py-1 rounded-t-lg text-white text-sm
                                            ${i === 0 ? 'bg-orange-500' : i === 1 ? 'bg-green-600' : i === 2 ? 'bg-blue-600' : i === 3 ? 'bg-red-600' : 'bg-purple-600'}`}>
                                            {l}
                                        </div>
                                    ))}
                                </div>
                                {/* Card Grid */}
                                <div className="grid grid-cols-5 gap-1 bg-white/5 p-1 rounded-b-lg">
                                    {formatBackendCard(card.masterCard?.numbers || card.numbers).map((row, rIdx) =>
                                        row.map((cell: any, cIdx: number) => {
                                            const numValue = cell?.number ?? cell?.Number;
                                            const isChecked = numValue === null || drawnNumbers.includes(numValue);
                                            return (
                                                <div key={`${rIdx}-${cIdx}`} className={`h-12 flex items-center justify-center rounded-lg text-lg font-black transition-all shadow-md
                                                    ${isChecked ? 'bg-green-500 text-white scale-95 shadow-inner' : 'bg-[#fff5d7] text-slate-900 border-b-4 border-black/10'}`}>
                                                    {numValue ?? '★'}
                                                </div>
                                            );
                                        })
                                    )}
                                </div>
                                <p className="text-center text-[10px] font-bold text-orange-500/80 mt-2 uppercase tracking-widest">Board No.{card.masterCardId}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </div>

            {/* Sticky Bingo Button */}
            <div className="absolute bottom-20 left-[140px] right-0 px-6 pointer-events-none">
                <button
                    onClick={handleClaimBingo}
                    disabled={!isCountingUp}
                    className={`w-full pointer-events-auto py-5 rounded-2xl font-black text-4xl text-white shadow-[0_8px_0_rgb(194,65,12)] active:translate-y-1 active:shadow-none transition-all transform
                        ${isCountingUp ? 'bg-orange-600 hover:bg-orange-500' : 'bg-slate-700 shadow-none opacity-50 cursor-not-allowed'}`}
                >
                    BINGO!
                </button>
            </div>

            {/* Bottom Nav Bar */}
            <div className="p-4 grid grid-cols-2 gap-4 bg-[#0f172a] border-t border-white/5 z-20">
                <button onClick={() => window.location.reload()} className="bg-[#3b82f6] hover:bg-[#2563eb] py-3 rounded-full font-black text-sm shadow-lg shadow-blue-500/20 transition-all uppercase tracking-widest">Refresh</button>
                <button onClick={onLeave} className="bg-orange-600 hover:bg-orange-500 py-3 rounded-full font-black text-sm shadow-lg shadow-orange-500/20 transition-all uppercase tracking-widest">Leave</button>
            </div>
        </div>
    );
};