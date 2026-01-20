import { useEffect, useState, useRef } from 'react';
import * as signalR from '@microsoft/signalr';
import { getRoom, getMyCards, claimBingo } from '../services/api';

export const GameRoom = ({ roomId, userId, onLeave }: { roomId: number, userId: number, onLeave: () => void }) => {
    const [cards, setCards] = useState<any[]>([]);
    const [drawnNumbers, setDrawnNumbers] = useState<number[]>([]);
    const [currentNumber, setCurrentNumber] = useState<{ letter: string, val: number } | null>(null);
    const connectionRef = useRef<signalR.HubConnection | null>(null);

    // Helper to get letter (Solves TS6133 by using it in updateCurrentNumber)
    const getCallLetter = (n: number) => {
        if (n <= 15) return 'B';
        if (n <= 30) return 'I';
        if (n <= 45) return 'N';
        if (n <= 60) return 'G';
        return 'O';
    };

    const updateCurrentNumber = (num: number) => {
        if (!num) return;
        setCurrentNumber({ letter: getCallLetter(num), val: num });
    };

    useEffect(() => {
        const initGame = async () => {
            const roomRes = await getRoom(roomId);
            const cardRes = await getMyCards(roomId, userId);

            if (roomRes.data) {
                const called = roomRes.data.calledNumbers.map((n: any) => n.number);
                setDrawnNumbers(called);
                updateCurrentNumber(called[called.length - 1]);
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

            await connection.start();
            await connection.invoke("JoinRoomGroup", roomId.toString());
            connectionRef.current = connection;
        };

        initGame();
        return () => { connectionRef.current?.stop(); };
    }, [roomId, userId]);

    const formatBackendCard = (numbers: any[]) => {
        const grid = Array(5).fill(null).map(() => Array(5).fill(null));
        numbers.forEach(n => {
            grid[n.positionRow - 1][n.positionCol - 1] = n;
        });
        return grid;
    };

    // Attached to button (Solves TS6133)
    const handleClaimBingo = async () => {
        const res = await claimBingo(roomId, userId);
        if (res.isFailed) alert(res.message);
        else alert("BINGO CLAIMED! Checking...");
    };

    return (
        <div className="flex flex-col h-screen bg-slate-950 text-white overflow-hidden font-sans">
            {/* Header Stats Bar - Best Bingo Style */}
            <div className="bg-indigo-900/50 p-2 grid grid-cols-5 text-center gap-1 text-[10px] uppercase font-bold border-b border-white/10">
                <div className="flex flex-col"><span className="text-indigo-400 opacity-70">Game ID</span><span>{roomId}</span></div>
                <div className="flex flex-col border-l border-white/10"><span className="text-indigo-400 opacity-70">Derash</span><span>696</span></div>
                <div className="flex flex-col border-l border-white/10"><span className="text-indigo-400 opacity-70">Players</span><span>84</span></div>
                <div className="flex flex-col border-l border-white/10"><span className="text-indigo-400 opacity-70">Bet</span><span>10</span></div>
                <div className="flex flex-col border-l border-white/10"><span className="text-indigo-400 opacity-70">Call</span><span>{drawnNumbers.length}</span></div>
            </div>

            <div className="flex flex-1 overflow-hidden">
                {/* LEFT SIDEBAR: 1-75 Grid */}
                <div className="w-40 bg-slate-900/40 border-r border-white/10 flex flex-col h-full shrink-0">
                    <div className="grid grid-cols-5 p-1 text-center font-black text-indigo-400 border-b border-white/10 bg-slate-900/60">
                        {['B', 'I', 'N', 'G', 'O'].map(l => <div key={l} className="text-xs">{l}</div>)}
                    </div>
                    <div className="flex-1 overflow-y-auto p-1 grid grid-cols-5 gap-0.5 custom-scrollbar">
                        {Array.from({ length: 15 }).map((_, rIdx) => (
                            [0, 15, 30, 45, 60].map(offset => {
                                const num = rIdx + 1 + offset;
                                const isDrawn = drawnNumbers.includes(num);
                                return (
                                    <div key={num} className={`aspect-square flex items-center justify-center rounded-sm text-[10px] font-bold transition-colors ${isDrawn ? 'bg-green-600 text-white shadow-[0_0_5px_rgba(22,163,74,0.5)]' : 'bg-slate-800/50 text-slate-500'
                                        }`}>
                                        {num}
                                    </div>
                                );
                            })
                        ))}
                    </div>
                </div>

                {/* MAIN GAMEPLAY AREA */}
                <div className="flex-1 flex flex-col p-3 overflow-y-auto bg-slate-950/50">
                    {/* Current Call Section - Pill Style */}
                    <div className="flex items-center justify-between mb-4 bg-indigo-600/20 p-3 rounded-2xl border border-indigo-500/30">
                        <span className="text-lg italic font-black text-white/90">playing</span>
                        <div className="flex items-center gap-3">
                            <span className="text-[10px] uppercase font-bold text-indigo-300">Current Call</span>
                            <div className="w-16 h-16 bg-slate-900 rounded-full flex flex-col items-center justify-center border-4 border-indigo-500 shadow-2xl">
                                <span className="text-[10px] font-black leading-none text-indigo-400">{currentNumber?.letter}</span>
                                <span className="text-2xl font-black leading-none">{currentNumber?.val || '--'}</span>
                            </div>
                        </div>
                    </div>

                    {/* Cards Stack */}
                    <div className="space-y-6 pb-40">
                        {cards.map((card) => (
                            <div key={card.cardId} className="bg-[#fefce8] p-3 rounded-xl shadow-2xl relative overflow-hidden">
                                <div className="grid grid-cols-5 text-center font-black text-lg mb-1">
                                    <span className="text-orange-500">B</span><span className="text-green-600">I</span>
                                    <span className="text-blue-600">N</span><span className="text-red-500">G</span>
                                    <span className="text-purple-600">O</span>
                                </div>
                                <div className="grid grid-cols-5 gap-1">
                                    {formatBackendCard(card.masterCard.numbers).map((row, rIdx) =>
                                        row.map((cell: any, cIdx: number) => {
                                            const isChecked = cell.number === null || drawnNumbers.includes(cell.number);
                                            return (
                                                <div key={`${rIdx}-${cIdx}`} className={`h-11 flex items-center justify-center rounded-md border border-black/5 text-lg font-black transition-all ${isChecked ? 'bg-green-500 text-white shadow-inner scale-[0.98]' : 'bg-white text-slate-800'
                                                    }`}>
                                                    {cell.number ?? '★'}
                                                </div>
                                            );
                                        })
                                    )}
                                </div>
                                <p className="text-center text-[10px] font-bold text-red-500/60 mt-2 uppercase tracking-tighter">Board No.{card.masterCardId}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </div>

            {/* Sticky Bingo Button Container */}
            <div className="absolute bottom-20 left-40 right-0 px-4 pointer-events-none">
                <button
                    onClick={handleClaimBingo}
                    className="w-full pointer-events-auto bg-orange-500 hover:bg-orange-400 py-4 rounded-2xl font-black text-3xl text-white shadow-[0_6px_0_rgb(194,65,12)] active:translate-y-1 active:shadow-none transition-all"
                >
                    BINGO!
                </button>
            </div>

            {/* Bottom Nav Bar */}
            <div className="p-3 grid grid-cols-2 gap-4 bg-slate-900 border-t border-white/10 z-10">
                <button className="bg-blue-500 hover:bg-blue-400 py-2.5 rounded-full font-bold text-sm shadow-lg transition-colors">Refresh</button>
                <button onClick={onLeave} className="bg-orange-500 hover:bg-orange-400 py-2.5 rounded-full font-bold text-sm shadow-lg transition-colors">Leave</button>
            </div>
        </div>
    );
};