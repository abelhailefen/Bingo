import { useEffect, useState, useRef } from 'react';
import * as signalR from '@microsoft/signalr';
import {
    joinAutoLobby,
    selectCardLock,
    getMasterCard,
    getTakenCards,
    getMyCards
} from '../services/api';
import type { MasterCard } from '../types/gameplay';

interface LobbyProps {
    userId: number;
    onEnterGame: (id: number) => void;
}

export const Lobby = ({ userId, onEnterGame }: LobbyProps) => {
    const [roomId, setRoomId] = useState<number | null>(null);
    const [lockedCards, setLockedCards] = useState<number[]>([]); // Cards taken by OTHERS
    const [myCards, setMyCards] = useState<MasterCard[]>([]);     // Full card objects for ME
    const [countdown, setCountdown] = useState(60);
    const connectionRef = useRef<signalR.HubConnection | null>(null);

    // Helpers to handle Casing variations from .NET API (PascalCase vs camelCase)
    const getCardId = (obj: any): number => {
        if (!obj) return 0;
        return obj.masterCardId ?? obj.MasterCardId ?? obj.master_card_id ?? 0;
    };

    const getNumbers = (obj: any): any[] => {
        if (!obj) return [];
        return obj.numbers ?? obj.Numbers ?? [];
    };

    // 1. Countdown Timer
    useEffect(() => {
        const timer = setInterval(() => setCountdown(p => p > 0 ? p - 1 : 60), 1000);
        return () => clearInterval(timer);
    }, []);

    // 2. Initialize Lobby and SignalR
    useEffect(() => {
        const initLobby = async () => {
            try {
                const res = await joinAutoLobby(userId);
                if (res?.data) {
                    const rId = res.data.roomId;
                    setRoomId(rId);

                    // Fetch initial room state
                    const [takenRes, myCardsRes] = await Promise.all([
                        getTakenCards(rId),
                        getMyCards(rId, userId)
                    ]);

                    // Initial sync of my own cards (Full objects for preview)
                    if (myCardsRes.data) {
                        const existing = myCardsRes.data.map((c: any) => c.masterCard || c.MasterCard);
                        setMyCards(existing.filter(Boolean));
                    }

                    // Initial sync of cards taken by OTHERS
                    if (takenRes.data) {
                        const myIds = myCardsRes.data?.map((c: any) => getCardId(c.masterCard || c.MasterCard)) || [];
                        const othersTaken = takenRes.data
                            .map(id => Number(id))
                            .filter(id => !myIds.includes(id));
                        setLockedCards(othersTaken);
                    }

                    connectSignalR(rId);
                }
            } catch (err) {
                console.error("Lobby Init Error:", err);
            }
        };

        initLobby();

        return () => {
            if (connectionRef.current) {
                connectionRef.current.stop();
            }
        };
    }, [userId]);

    const connectSignalR = async (rId: number) => {
        // Build connection
        const connection = new signalR.HubConnectionBuilder()
            .withUrl("/bingohub") // Ensure this matches your .NET MapHub path
            .withAutomaticReconnect()
            .configureLogging(signalR.LogLevel.Information)
            .build();

        // Listener for real-time updates from other players
        connection.on("CardSelectionChanged", (cardId: number, isLocked: boolean, senderId: number) => {
            const cid = Number(cardId);
            const isMe = senderId.toString() === userId.toString();

            // If the message is from me, ignore it. My local state is already updated via handleToggleCard.
            if (isMe) return;

            setLockedCards(prev => {
                if (isLocked) {
                    return [...new Set([...prev, cid])]; // Add to greyed out list
                } else {
                    return prev.filter(id => id !== cid); // Remove from greyed out list
                }
            });
        });

        try {
            await connection.start();
            console.log("SignalR Connected");
            await connection.invoke("JoinRoomGroup", rId.toString());
            connectionRef.current = connection;
        } catch (err) {
            console.error("SignalR Connection Error:", err);
        }
    };

    // 3. Select / Deselect Logic
    const handleToggleCard = async (cardId: number) => {
        if (!roomId) return;

        const isAlreadyMine = myCards.some(c => getCardId(c) === cardId);

        try {
            // API Call: Source of Truth
            const res = await selectCardLock(roomId, cardId, !isAlreadyMine, userId);

            if (res && !res.isFailed) {
                if (!isAlreadyMine) {
                    // SELECTING: Fetch full template for preview section
                    const cardData = await getMasterCard(roomId, cardId);
                    if (cardData.data) {
                        setMyCards(prev => [...prev, cardData.data]);
                    }
                } else {
                    // DESELECTING: Remove from local preview
                    setMyCards(prev => prev.filter(c => getCardId(c) !== cardId));
                }
            } else {
                // If API fails (e.g. someone else clicked a millisecond faster)
                alert(res.message || "Action failed!");
                // Refresh taken cards to fix UI sync
                const takenRes = await getTakenCards(roomId);
                setLockedCards(takenRes.data.map(id => Number(id)));
            }
        } catch (err) {
            console.error("Toggle Error:", err);
        }
    };

    const renderCardGrid = (numbers: any[]) => {
        const grid = Array(5).fill(null).map(() => Array(5).fill(null));
        numbers.forEach(n => {
            const r = (n.positionRow ?? n.PositionRow) - 1;
            const c = (n.positionCol ?? n.PositionCol) - 1;
            const val = n.number !== undefined ? n.number : n.Number;
            if (grid[r]) grid[r][c] = val;
        });

        return grid.map((row, rIdx) => (
            <div key={rIdx} className="grid grid-cols-5 gap-0.5">
                {row.map((num, cIdx) => (
                    <div
                        key={cIdx}
                        className={`h-7 sm:h-8 flex items-center justify-center border border-black/5 text-[11px] font-bold rounded-sm ${num === null ? 'bg-green-500 text-white' : 'bg-white text-slate-800'}`}
                    >
                        {num ?? '★'}
                    </div>
                ))}
            </div>
        ));
    };

    return (
        <div className="min-h-screen bg-slate-950 text-white flex flex-col font-sans">
            {/* Header Stats */}
            <div className="grid grid-cols-3 gap-3 px-4 py-6 bg-indigo-700/20">
                <div className="bg-white rounded-2xl py-2 flex flex-col items-center justify-center text-slate-900 shadow-xl">
                    <span className="text-[9px] font-black uppercase text-indigo-400">Room</span>
                    <span className="text-xl font-black">{roomId ?? '...'}</span>
                </div>
                <div className="bg-white rounded-2xl py-2 flex flex-col items-center justify-center text-slate-900 shadow-xl">
                    <span className="text-[9px] font-black uppercase text-indigo-400">Stake</span>
                    <span className="text-xl font-black">10</span>
                </div>
                <div className="bg-white rounded-2xl py-2 flex flex-col items-center justify-center text-slate-900 shadow-xl">
                    <span className="text-[9px] font-black uppercase text-indigo-400">Starts</span>
                    <span className="text-sm font-black text-indigo-600">{countdown}s</span>
                </div>
            </div>

            <div className="flex-1 p-4 overflow-y-auto">
                {/* 1-100 Number Selection Grid */}
                <div className="grid grid-cols-10 gap-1.5 max-w-xl mx-auto mb-8">
                    {Array.from({ length: 100 }, (_, i) => i + 1).map(id => {
                        const isMine = myCards.some(c => getCardId(c) === id);
                        const isTakenByOther = lockedCards.includes(id);

                        return (
                            <button
                                key={id}
                                disabled={isTakenByOther}
                                onClick={() => handleToggleCard(id)}
                                className={`aspect-square flex items-center justify-center text-[11px] font-bold rounded transition-all 
                                    ${isMine
                                        ? 'bg-orange-500 text-white ring-2 ring-orange-400 scale-110 z-10 shadow-lg'
                                        : isTakenByOther
                                            ? 'bg-slate-800 text-slate-600 opacity-40 cursor-not-allowed'
                                            : 'bg-indigo-500/30 text-white/90 hover:bg-indigo-500/50'}`}
                            >
                                {id}
                            </button>
                        );
                    })}
                </div>

                {/* Selected Cards Preview Section */}
                <div className="max-w-md mx-auto space-y-6 pb-24">
                    <h3 className="text-center text-xs font-bold text-indigo-400 uppercase tracking-widest">
                        Your Selected Boards ({myCards.length}/2)
                    </h3>

                    {myCards.map((card) => (
                        <div key={getCardId(card)} className="relative bg-[#fefce8] p-3 rounded-xl shadow-2xl animate-in fade-in zoom-in duration-300">
                            {/* Deselect X Button */}
                            <button
                                onClick={() => handleToggleCard(getCardId(card))}
                                className="absolute -top-2 -right-2 bg-red-500 hover:bg-red-600 text-white w-7 h-7 rounded-full flex items-center justify-center shadow-lg border-2 border-white z-20"
                            >
                                <span className="font-bold text-lg">×</span>
                            </button>

                            <div className="grid grid-cols-5 text-center font-black text-[12px] mb-2">
                                <span className="text-orange-600">B</span><span className="text-green-600">I</span>
                                <span className="text-blue-600">N</span><span className="text-red-600">G</span>
                                <span className="text-purple-600">O</span>
                            </div>

                            {renderCardGrid(getNumbers(card))}

                            <p className="text-center text-[10px] font-bold text-slate-400 mt-2 uppercase tracking-tighter">
                                Board #{getCardId(card)}
                            </p>
                        </div>
                    ))}

                    {myCards.length === 0 && (
                        <div className="text-center py-10 border-2 border-dashed border-slate-800 rounded-2xl">
                            <p className="text-slate-500 italic text-sm">Select up to 2 cards from the grid above to join the game</p>
                        </div>
                    )}
                </div>
            </div>

            {/* Fixed Footer */}
            <div className="fixed bottom-0 left-0 right-0 p-4 grid grid-cols-2 gap-4 bg-slate-900/90 backdrop-blur-md border-t border-white/10 z-30">
                <button className="bg-slate-800 py-3 rounded-xl font-bold text-sm hover:bg-slate-700 transition-colors">
                    BACK
                </button>
                <button
                    onClick={() => roomId && onEnterGame(roomId)}
                    disabled={myCards.length === 0}
                    className={`py-3 rounded-xl font-bold text-sm transition-all ${myCards.length > 0
                        ? 'bg-orange-500 hover:bg-orange-400 shadow-lg shadow-orange-500/20 text-white'
                        : 'bg-slate-800 text-slate-600 cursor-not-allowed'
                        }`}
                >
                    START GAME
                </button>
            </div>
        </div>
    );
};