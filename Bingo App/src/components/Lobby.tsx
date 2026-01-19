import { useEffect, useState, useRef } from 'react';
import * as signalR from '@microsoft/signalr';
import { joinAutoLobby, selectCardLock, getMasterCard } from '../services/api';
import type { MasterCard } from '../types/gameplay';

interface LobbyProps {
    userId: number;
    onEnterGame: (roomId: number) => void;
}

export const Lobby = ({ userId, onEnterGame }: LobbyProps) => {
    const [roomId, setRoomId] = useState<number | null>(null);
    const [lockedCards, setLockedCards] = useState<number[]>([]);
    const [myCards, setMyCards] = useState<MasterCard[]>([]);
    const connectionRef = useRef<signalR.HubConnection | null>(null);

    // 1. Join Lobby on Mount
    useEffect(() => {
        const initLobby = async () => {
            try {
                const res = await joinAutoLobby(userId);
                if (res && res.data) {
                    setRoomId(res.data.roomId);
                    connectSignalR(res.data.roomId);
                }
            } catch (err) {
                console.error("Lobby Init Failed", err);
            }
        };
        if (userId) initLobby();

        // Cleanup SignalR on unmount
        return () => {
            connectionRef.current?.stop();
        };
    }, [userId]);

    // 2. SignalR Setup
    const connectSignalR = async (rId: number) => {
        const connection = new signalR.HubConnectionBuilder()
            .withUrl("/bingohub")
            .withAutomaticReconnect()
            .build();

        // Listen for other players selecting/deselecting cards
        connection.on("CardSelectionChanged", (cardId: number, isLocked: boolean, senderId: number) => {
            if (senderId === userId) return;
            setLockedCards(prev => isLocked
                ? [...new Set([...prev, cardId])]
                : prev.filter(id => id !== cardId)
            );
        });

        // Listen for system game start (Optional logic)
        connection.on("GameStarted", (startedRoomId: number) => {
            if (startedRoomId === rId) onEnterGame(startedRoomId);
        });

        try {
            await connection.start();
            await connection.invoke("JoinRoomGroup", rId.toString());
            connectionRef.current = connection;
        } catch (err) {
            console.error("SignalR Connection Error: ", err);
        }
    };

    // 3. Toggle Card Selection (Select/Deselect)
    const handleToggleCard = async (cardId: number) => {
        if (!roomId) return;
        const existingCard = myCards.find(c => c.masterCardId === cardId);

        try {
            if (existingCard) {
                // --- DESELECT LOGIC ---
                const res = await selectCardLock(roomId, cardId, false);
                if (res && !res.isFailed) {
                    setMyCards(prev => prev.filter(c => c.masterCardId !== cardId));
                }
            } else {
                // --- SELECT LOGIC ---
                if (myCards.length >= 2) return; // UI safeguard

                const res = await selectCardLock(roomId, cardId, true);
                if (res && !res.isFailed) {
                    // Fetch full card data (B-I-N-G-O columns) to show in preview
                    const cardData = await getMasterCard(roomId, cardId);
                    if (cardData.data) {
                        setMyCards(prev => [...prev, cardData.data]);
                    }
                } else {
                    alert(res.message || "This card was just taken!");
                }
            }
        } catch (err) {
            console.error("Card selection toggle failed", err);
        }
    };

    return (
        <div className="min-h-screen bg-slate-950 text-slate-100 p-4 md:p-8 font-sans">
            <div className="max-w-5xl mx-auto space-y-8">

                {/* Header Info Panel */}
                <div className="flex flex-col md:flex-row justify-between items-center gap-4 bg-slate-900 p-6 rounded-2xl border border-slate-800 shadow-xl">
                    <div>
                        <h1 className="text-2xl font-black tracking-tight text-white uppercase">Bingo Lobby</h1>
                        <p className="text-slate-400 text-sm">Room ID: <span className="text-indigo-400 font-mono">#{roomId ?? '---'}</span></p>
                    </div>
                    <div className="flex gap-6">
                        <div className="text-center">
                            <p className="text-[10px] text-slate-500 uppercase font-bold tracking-widest">Stake</p>
                            <p className="text-xl font-bold text-orange-500">10.00</p>
                        </div>
                        <div className="text-center border-l border-slate-800 pl-6">
                            <p className="text-[10px] text-slate-500 uppercase font-bold tracking-widest">Selected</p>
                            <p className="text-xl font-bold text-indigo-400">{myCards.length} / 2</p>
                        </div>
                    </div>
                </div>

                {/* Card Preview Widgets */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {myCards.length === 0 && (
                        <div className="col-span-full h-32 flex items-center justify-center border-2 border-dashed border-slate-800 rounded-2xl text-slate-600 italic">
                            Select up to two cards from the grid below...
                        </div>
                    )}
                    {myCards.map(card => (
                        <div key={card.masterCardId} className="bg-slate-900 border border-indigo-500/30 rounded-2xl p-4 flex gap-4 shadow-2xl transition-all">
                            <div className="flex-1">
                                <p className="text-[10px] font-bold text-indigo-400 mb-2 uppercase tracking-tighter">Master Card #{card.masterCardId}</p>
                                <div className="grid grid-cols-5 gap-1 bg-slate-950 p-2 rounded-lg border border-slate-800">
                                    {card.numbers.map((n, i) => (
                                        <div key={i} className={`aspect-square flex items-center justify-center text-[10px] font-bold rounded-sm border border-slate-800/30 ${n.number === null ? 'bg-orange-500 text-white shadow-[0_0_8px_rgba(249,115,22,0.4)]' : 'text-slate-300'}`}>
                                            {n.number ?? '*'}
                                        </div>
                                    ))}
                                </div>
                            </div>
                            <div className="flex flex-col justify-end">
                                <button
                                    onClick={() => handleToggleCard(card.masterCardId)}
                                    className="bg-red-500/10 hover:bg-red-500/20 text-red-500 text-[10px] font-bold py-2 px-3 rounded-lg border border-red-500/20 transition-colors uppercase"
                                >
                                    Remove
                                </button>
                            </div>
                        </div>
                    ))}
                </div>

                {/* 1-100 Selection Grid */}
                <div className="bg-slate-900 p-6 rounded-3xl border border-slate-800 shadow-2xl">
                    <div className="grid grid-cols-5 sm:grid-cols-10 gap-2">
                        {Array.from({ length: 100 }, (_, i) => i + 1).map(id => {
                            const isLocked = lockedCards.includes(id);
                            const isMe = myCards.some(c => c.masterCardId === id);

                            let btnClasses = "h-12 rounded-xl font-black text-sm transition-all duration-200 shadow-sm ";

                            if (isMe) {
                                btnClasses += "bg-orange-500 text-white ring-4 ring-orange-500/30 scale-110 z-10 shadow-lg shadow-orange-500/20";
                            } else if (isLocked) {
                                btnClasses += "bg-slate-800 text-slate-600 opacity-30 cursor-not-allowed";
                            } else {
                                btnClasses += "bg-indigo-600 hover:bg-indigo-500 text-white hover:scale-105 active:scale-95";
                            }

                            return (
                                <button
                                    key={id}
                                    disabled={isLocked && !isMe}
                                    onClick={() => handleToggleCard(id)}
                                    className={btnClasses}
                                >
                                    {id}
                                </button>
                            );
                        })}
                    </div>
                </div>

                {/* Footer Navigation Actions */}
                <div className="flex justify-between items-center bg-slate-900 p-4 rounded-2xl border border-slate-800 shadow-lg">
                    <button className="px-8 py-3 rounded-xl font-bold text-slate-400 hover:bg-slate-800 transition-colors uppercase text-sm tracking-widest">
                        Back
                    </button>
                    <button
                        disabled={myCards.length === 0}
                        onClick={() => roomId && onEnterGame(roomId)}
                        className={`px-12 py-3 rounded-xl font-black transition-all shadow-xl uppercase tracking-widest ${myCards.length > 0
                                ? 'bg-indigo-500 hover:bg-indigo-400 text-white cursor-pointer hover:-translate-y-0.5'
                                : 'bg-slate-800 text-slate-600 cursor-not-allowed'
                            }`}
                    >
                        Enter Game
                    </button>
                </div>

                <p className="text-center text-[10px] text-slate-600 font-mono tracking-tighter uppercase">
                    Best Bingo Engine &copy; 2024 - All Rights Reserved
                </p>
            </div>
        </div>
    );
};