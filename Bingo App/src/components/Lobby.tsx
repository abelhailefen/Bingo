import { useEffect, useState, useRef } from 'react';
import * as signalR from '@microsoft/signalr';
import { joinAutoLobby, selectCardLock, getMasterCard } from '../services/api';
import type { MasterCard } from '../types/gameplay';

export const Lobby = ({ userId }: { userId: number }) => {
    const [roomId, setRoomId] = useState<number | null>(null);
    const [lockedCards, setLockedCards] = useState<number[]>([]);
    const [myCards, setMyCards] = useState<MasterCard[]>([]);
    const connectionRef = useRef<signalR.HubConnection | null>(null);

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
    }, [userId]);

    const connectSignalR = async (rId: number) => {
        const connection = new signalR.HubConnectionBuilder()
            .withUrl("/bingohub")
            .withAutomaticReconnect()
            .build();

        connection.on("CardSelectionChanged", (cardId: number, isLocked: boolean, senderId: number) => {
            if (senderId === userId) return;
            setLockedCards(prev => isLocked
                ? [...new Set([...prev, cardId])]
                : prev.filter(id => id !== cardId)
            );
        });

        await connection.start();
        await connection.invoke("JoinRoomGroup", rId.toString());
        connectionRef.current = connection;
    };

    const handleToggleCard = async (cardId: number) => {
        if (!roomId) return;
        const existingCard = myCards.find(c => c.masterCardId === cardId);

        try {
            if (existingCard) {
                // DESELECT logic
                const res = await selectCardLock(roomId, cardId, false);
                if (res && !res.isFailed) {
                    setMyCards(prev => prev.filter(c => c.masterCardId !== cardId));
                }
            } else {
                // SELECT logic (Max 2)
                if (myCards.length >= 2) return;

                const res = await selectCardLock(roomId, cardId, true);
                if (res && !res.isFailed) {
                    const cardData = await getMasterCard(roomId, cardId);
                    setMyCards(prev => [...prev, cardData.data]);
                }
            }
        } catch (err) {
            console.error("Card selection toggle failed", err);
        }
    };

    return (
        <div className="min-h-screen bg-slate-950 text-slate-100 p-4 md:p-8">
            <div className="max-w-5xl mx-auto space-y-8">

                {/* Header Info */}
                <div className="flex flex-col md:flex-row justify-between items-center gap-4 bg-slate-900 p-6 rounded-2xl border border-slate-800 shadow-xl">
                    <div>
                        <h1 className="text-2xl font-black tracking-tight text-white">BINGO LOBBY</h1>
                        <p className="text-slate-400 text-sm">Room ID: <span className="text-indigo-400 font-mono">#{roomId ?? '---'}</span></p>
                    </div>
                    <div className="flex gap-6">
                        <div className="text-center">
                            <p className="text-[10px] text-slate-500 uppercase font-bold">Stake</p>
                            <p className="text-xl font-bold text-orange-500">10.00</p>
                        </div>
                        <div className="text-center border-l border-slate-800 pl-6">
                            <p className="text-[10px] text-slate-500 uppercase font-bold">Cards</p>
                            <p className="text-xl font-bold text-indigo-400">{myCards.length} / 2</p>
                        </div>
                    </div>
                </div>

                {/* Card Preview Section */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {myCards.length === 0 && (
                        <div className="col-span-full h-32 flex items-center justify-center border-2 border-dashed border-slate-800 rounded-2xl text-slate-600">
                            Select up to two cards from the grid below to preview them
                        </div>
                    )}
                    {myCards.map(card => (
                        <div key={card.masterCardId} className="bg-slate-900 border border-indigo-500/30 rounded-2xl p-4 flex gap-4 shadow-2xl animate-in fade-in slide-in-from-bottom-2">
                            <div className="flex-1">
                                <p className="text-xs font-bold text-indigo-400 mb-2 uppercase">Master Card #{card.masterCardId}</p>
                                <div className="grid grid-cols-5 gap-1 bg-slate-950 p-2 rounded-lg border border-slate-800">
                                    {card.numbers.map((n, i) => (
                                        <div key={i} className={`aspect-square flex items-center justify-center text-[10px] font-bold rounded-sm border border-slate-800/50 ${n.number === null ? 'bg-orange-500/20 text-orange-500' : 'text-slate-300'}`}>
                                            {n.number ?? '★'}
                                        </div>
                                    ))}
                                </div>
                            </div>
                            <div className="flex flex-col justify-end">
                                <button
                                    onClick={() => handleToggleCard(card.masterCardId)}
                                    className="bg-red-500/10 hover:bg-red-500/20 text-red-500 text-[10px] font-bold py-2 px-3 rounded-lg transition-colors"
                                >
                                    REMOVE
                                </button>
                            </div>
                        </div>
                    ))}
                </div>

                {/* Main Selection Grid */}
                <div className="bg-slate-900 p-6 rounded-3xl border border-slate-800 shadow-2xl">
                    <div className="grid grid-cols-5 sm:grid-cols-10 gap-2">
                        {Array.from({ length: 100 }, (_, i) => i + 1).map(id => {
                            const isLocked = lockedCards.includes(id);
                            const isMe = myCards.some(c => c.masterCardId === id);

                            let btnClasses = "h-12 rounded-xl font-black text-sm transition-all duration-200 shadow-sm ";

                            if (isMe) {
                                btnClasses += "bg-orange-500 text-white ring-4 ring-orange-500/30 scale-105 z-10 shadow-orange-500/20";
                            } else if (isLocked) {
                                btnClasses += "bg-slate-800 text-slate-600 opacity-40 cursor-not-allowed";
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

                {/* Footer Actions */}
                <div className="flex justify-between items-center bg-slate-900 p-4 rounded-2xl border border-slate-800">
                    <button className="px-8 py-3 rounded-xl font-bold text-slate-400 hover:bg-slate-800 transition-colors">
                        Back
                    </button>
                    <button
                        disabled={myCards.length === 0}
                        className={`px-12 py-3 rounded-xl font-black transition-all shadow-lg ${myCards.length > 0
                                ? 'bg-indigo-500 hover:bg-indigo-400 text-white'
                                : 'bg-slate-800 text-slate-600 cursor-not-allowed'
                            }`}
                    >
                        ENTER GAME
                    </button>
                </div>
            </div>
        </div>
    );
};