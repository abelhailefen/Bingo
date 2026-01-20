import { useEffect, useState, useRef } from 'react';
import * as signalR from '@microsoft/signalr';
import { getRoom, getMyCards, claimBingo } from '../services/api';

export const GameRoom = ({ roomId, userId, onLeave: _onLeave }: { roomId: number, userId: number, onLeave: () => void }) => {
    const [cards, setCards] = useState<any[]>([]);
    const [drawnNumbers, setDrawnNumbers] = useState<number[]>([]);
    const [currentNumber, setCurrentNumber] = useState<{ letter: string, val: number } | null>(null);
    const connectionRef = useRef<signalR.HubConnection | null>(null);

    useEffect(() => {
        const initGame = async () => {
            // 1. Fetch Initial State
            const roomRes = await getRoom(roomId);
            const cardRes = await getMyCards(roomId, userId);

            if (roomRes.data) {
                const called = roomRes.data.calledNumbers.map((n: any) => n.number);
                setDrawnNumbers(called);
                updateCurrentNumber(called[called.length - 1]);
            }
            if (cardRes.data) setCards(cardRes.data);

            // 2. Setup SignalR
            const connection = new signalR.HubConnectionBuilder()
                .withUrl("/bingohub")
                .withAutomaticReconnect()
                .build();

            connection.on("NewNumberCalled", (number: number) => {
                setDrawnNumbers(prev => [...prev, number]);
                updateCurrentNumber(number);
                playPopSound(); // Optional: Add a sound effect
            });

            await connection.start();
            await connection.invoke("JoinRoomGroup", roomId.toString());
            connectionRef.current = connection;
        };

        initGame();
        return () => { connectionRef.current?.stop(); };
    }, [roomId, userId]);

    const updateCurrentNumber = (num: number) => {
        if (!num) return;
        const letter = num <= 15 ? 'B' : num <= 30 ? 'I' : num <= 45 ? 'N' : num <= 60 ? 'G' : 'O';
        setCurrentNumber({ letter, val: num });
    };
    const formatBackendCard = (numbers: any[]) => {
        // Initialize a 5x5 null grid
        const grid = Array(5).fill(null).map(() => Array(5).fill(null));

        numbers.forEach(n => {
            // Subtract 1 because your DB positions are likely 1-indexed (1-5)
            // and JS arrays are 0-indexed (0-4)
            grid[n.positionRow - 1][n.positionCol - 1] = n;
        });
        return grid;
    };
    const handleClaimBingo = async () => {
        const res = await claimBingo(roomId, userId);
        if (res.isFailed) alert(res.message);
        else alert("BINGO CLAIMED! Checking...");
    };

    return (
        <div className="flex h-screen w-full bg-slate-950 text-white overflow-hidden">

            {/* LEFT PANEL: 1-75 PROGRESS BOARD */}
            <div className="w-64 bg-slate-900/50 border-r border-white/5 flex flex-col h-full overflow-hidden shrink-0">
                {/* Headers */}
                <div className="grid grid-cols-5 gap-1 p-2 bg-slate-900">
                    {['B', 'I', 'N', 'G', 'O'].map(l => (
                        <div key={l} className="text-center font-black text-indigo-400 text-lg">{l}</div>
                    ))}
                </div>

                {/* Scrollable Numbers Area */}
                <div className="flex-1 overflow-y-auto p-2 custom-scrollbar">
                    <div className="grid grid-cols-5 gap-1">
                        {/* 
                We create a flat list of 75 numbers. 
                The order is: Row 1 (1, 16, 31, 46, 61), Row 2 (2, 17, 32, 47, 62)... 
            */}
                        {Array.from({ length: 15 }).map((_, rowIdx) => {
                            const rowNum = rowIdx + 1;
                            return [0, 15, 30, 45, 60].map(offset => {
                                const num = rowNum + offset;
                                const isDrawn = drawnNumbers.includes(num);

                                return (
                                    <div
                                        key={num}
                                        className={`aspect-square flex items-center justify-center rounded text-[10px] font-bold transition-all duration-300 ${isDrawn
                                                ? 'bg-green-500 text-white shadow-[0_0_10px_rgba(34,197,94,0.4)] scale-95'
                                                : 'bg-slate-800 text-slate-600'
                                            }`}
                                    >
                                        {num}
                                    </div>
                                );
                            });
                        })}
                    </div>
                </div>
            </div>

            {/* RIGHT PANEL: GAMEPLAY */}
            <div className="flex-1 flex flex-col overflow-y-auto p-4 md:p-8 space-y-6">

                {/* Header Stats */}
                <div className="grid grid-cols-3 gap-2 bg-black/30 p-4 rounded-2xl border border-white/10">
                    <div className="text-center">
                        <p className="text-[10px] uppercase text-indigo-300">Room ID</p>
                        <p className="font-bold">{roomId}</p>
                    </div>
                    <div className="text-center border-x border-white/10">
                        <p className="text-[10px] uppercase text-indigo-300">Players</p>
                        <p className="font-bold">84</p>
                    </div>
                    <div className="text-center">
                        <p className="text-[10px] uppercase text-indigo-300">Call</p>
                        <p className="font-bold">{drawnNumbers.length}</p>
                    </div>
                </div>

                {/* Current Call Display */}
                <div className="flex items-center justify-between bg-indigo-600/40 p-6 rounded-3xl border-2 border-indigo-500/50">
                    <h2 className="text-xl font-bold italic">playing...</h2>
                    <div className="flex items-center gap-4">
                        <span className="text-indigo-200 font-semibold">Current Call</span>
                        <div className="w-20 h-20 bg-white rounded-full flex flex-col items-center justify-center shadow-2xl border-4 border-indigo-400">
                            <span className="text-indigo-900 text-xs font-black leading-none">{currentNumber?.letter}</span>
                            <span className="text-indigo-900 text-3xl font-black leading-none">{currentNumber?.val}</span>
                        </div>
                    </div>
                </div>

                {/* Player Boards */}
                <div className="flex flex-col gap-8 pb-24">
                    {cards.map((card) => (
                        <div key={card.cardId} className="bg-[#fefce8] p-3 rounded-xl shadow-2xl rotate-1">
                            <div className="flex justify-between items-center mb-1 px-1">
                                {['B', 'I', 'N', 'G', 'O'].map((l, i) => (
                                    <span key={i} className={`w-10 text-center font-black text-lg ${l === 'B' ? 'text-orange-500' : l === 'I' ? 'text-green-600' : l === 'N' ? 'text-blue-600' : l === 'G' ? 'text-red-500' : 'text-purple-600'
                                        }`}>{l}</span>
                                ))}
                            </div>
                            <div className="grid grid-cols-5 gap-1">
                                {formatBackendCard(card.masterCard.numbers).map((row, rIdx) =>
                                    row.map((cell: any, cIdx: number) => {
                                        const isDrawn = cell.number === null || drawnNumbers.includes(cell.number);
                                        return (
                                            <div key={`${rIdx}-${cIdx}`} className={`h-12 flex items-center justify-center rounded-lg border-2 border-black/5 text-lg font-black transition-all ${isDrawn ? 'bg-green-500 text-white' : 'bg-white text-slate-800'
                                                }`}>
                                                {cell.number ?? '★'}
                                            </div>
                                        );
                                    })
                                )}
                            </div>
                            <p className="text-center text-[10px] font-bold text-red-500 mt-2">Board No.{card.masterCardId}</p>
                        </div>
                    ))}
                </div>

                {/* Footer Claim Button */}
                <div className="fixed bottom-0 right-0 w-3/4 p-4 bg-indigo-900/80 backdrop-blur-md">
                    <button
                        onClick={handleClaimBingo}
                        className="w-full bg-orange-500 hover:bg-orange-400 py-4 rounded-2xl font-black text-3xl shadow-[0_8px_0_rgb(194,65,12)] active:translate-y-1 active:shadow-none transition-all"
                    >
                        BINGO!
                    </button>
                </div>
            </div>
        </div>
    );
};

const playPopSound = () => {
    try { new Audio('/assets/pop.mp3').play(); } catch (e) { }
};