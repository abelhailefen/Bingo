import { useEffect, useRef, useState, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import * as signalR from '@microsoft/signalr';
import {
    joinAutoLobby,
    selectCardLock,
    getTakenCards,
    getMyCards,
    leaveLobby
} from '../services/api';
import {
    setLobbyData,
    updateMyCards,
    updateLockedCards,
    syncLockedCards,
    resetLobby
} from '../store/gameSlice';
import type { RootState, AppDispatch } from '../store';
import type { MasterCard } from '../types/gameplay';

interface LobbyProps {
    userId: number;
    wager: number;
    onEnterGame: (id: number) => void;
    onBack?: () => void;
}

export const Lobby = ({ userId, wager, onEnterGame, onBack }: LobbyProps) => {
    const dispatch = useDispatch<AppDispatch>();
    const connectionRef = useRef<signalR.HubConnection | null>(null);
    const roomIdRef = useRef<number | null>(null);

    const [countdown, setCountdown] = useState<number>(0);
    const [scheduledStartTime, setScheduledStartTime] = useState<string | null>(null);
    const [isReady, setIsReady] = useState(false); // Track if user pressed "Join Game"
    const [isJoining, setIsJoining] = useState(false); // UI loading state

    const { roomId, myCards, lockedCards } = useSelector((state: RootState) => state.game);

    useEffect(() => {
        roomIdRef.current = roomId;
    }, [roomId]);

    const getCardId = (obj: MasterCard | null): number => {
        if (!obj) return 0;
        // @ts-ignore
        return obj.masterCardId ?? obj.MasterCardId ?? 0;
    };

    const getNumbers = (obj: MasterCard): any[] => {
        // @ts-ignore
        return obj.numbers ?? obj.Numbers ?? [];
    };

    // Initialize Lobby - Wrapped in useCallback so we can call it to "Switch Rooms"
    const initLobby = useCallback(async () => {
        try {
            setIsReady(false);
            const res = await joinAutoLobby(userId, wager);
            if (res?.data) {
                const rId = res.data.roomId;
                setScheduledStartTime(res.data.scheduledStartTime);
                dispatch(setLobbyData({ roomId: rId, wager }));

                const [takenRes, myCardsRes] = await Promise.all([
                    getTakenCards(rId),
                    getMyCards(rId, userId)
                ]);

                if (myCardsRes.data) {
                    const existing = myCardsRes.data.map((c: any) => c.masterCard || c.MasterCard);
                    dispatch(updateMyCards(existing.filter(Boolean)));
                }

                if (takenRes.data) {
                    const myIds = myCardsRes.data?.map((c: any) => getCardId(c.masterCard || c.MasterCard)) || [];
                    const othersTaken = takenRes.data.filter((id: any) => !myIds.includes(Number(id)));
                    dispatch(updateLockedCards(othersTaken.map(Number)));
                }
                startSignalR(rId);
            }
        } catch (err) {
            console.error("Failed to init lobby:", err);
        }
    }, [userId, wager, dispatch]);

    useEffect(() => {
        initLobby();
        return () => {
            const currentRoomId = roomIdRef.current;
            if (currentRoomId) leaveLobby(currentRoomId, userId).catch(console.error);
            if (connectionRef.current) connectionRef.current.stop();
            dispatch(resetLobby());
        };
    }, [initLobby]);

    // Countdown Logic
    useEffect(() => {
        if (!scheduledStartTime) return;

        const interval = setInterval(() => {
            const now = new Date().getTime();
            const start = new Date(scheduledStartTime).getTime();
            const diff = Math.max(0, Math.floor((start - now) / 1000));

            setCountdown(diff);

            if (diff <= 0) {
                clearInterval(interval);
                // If the timer is up and user NOT ready, move them to a new room
                if (!isReady && !isJoining) {
                    console.log("Missed the window! Finding new room...");
                    initLobby();
                }
            }
        }, 1000);

        return () => clearInterval(interval);
    }, [scheduledStartTime, isReady, isJoining, initLobby]);

    const startSignalR = async (rId: number) => {
        // Stop existing if any
        if (connectionRef.current) await connectionRef.current.stop();

        const connection = new signalR.HubConnectionBuilder()
            .withUrl("/bingohub")
            .withAutomaticReconnect()
            .build();

        connection.on("CardSelectionChanged", (cardId: number, isLocked: boolean, senderId: number) => {
            if (senderId === userId) return;
            dispatch(syncLockedCards({ cardId: Number(cardId), isLocked }));
        });

        connection.on("GameStarted", (startedRoomId: number) => {
            // ONLY ENTER if the user clicked the button
            if (isReady) {
                onEnterGame(startedRoomId);
            }
        });

        try {
            await connection.start();
            await connection.invoke("JoinRoomGroup", rId.toString());
            connectionRef.current = connection;
        } catch (err) { console.error(err); }
    };

    const handleToggleCard = async (cardId: number) => {
        if (!roomId || countdown <= 3 || isReady) return; // Prevent changes if Ready

        const isMine = myCards.some((c: MasterCard) => getCardId(c) === cardId);
        try {
            if (!isMine && myCards.length >= 2) {
                const secondCardId = getCardId(myCards[1]);
                await selectCardLock(roomId, secondCardId, false, userId);
                const updatedAfterRelease = myCards.filter((c: MasterCard) => getCardId(c) !== secondCardId);
                dispatch(updateMyCards(updatedAfterRelease));
            }

            const res = await selectCardLock(roomId, cardId, !isMine, userId);
            if (res && !res.isFailed) {
                const myCardsRes = await getMyCards(roomId, userId);
                const cards = myCardsRes.data.map((c: any) => c.masterCard || c.MasterCard);
                dispatch(updateMyCards(cards));
            }
        } catch (err) { console.error(err); }
    };

    const handleConfirmJoin = () => {
        setIsJoining(true);
        // Simulate a small delay or API call if you need to mark "Ready" on DB
        setTimeout(() => {
            setIsReady(true);
            setIsJoining(false);
        }, 500);
    };

    const renderCardGrid = (numbers: any[]) => {
        const grid = Array(5).fill(null).map(() => Array(5).fill(null));
        numbers.forEach(n => {
            const r = (n.positionRow ?? n.PositionRow) - 1;
            const c = (n.positionCol ?? n.PositionCol) - 1;
            const val = n.number !== undefined ? n.number : n.Number;
            if (r >= 0 && r < 5 && c >= 0 && c < 5) grid[r][c] = val;
        });

        return grid.map((row, rIdx) => (
            <div key={rIdx} className="grid grid-cols-5 gap-0.5">
                {row.map((num, cIdx) => (
                    <div key={cIdx} className={`h-8 flex items-center justify-center border border-black/5 text-[11px] font-bold rounded-sm ${num === null ? 'bg-green-500 text-white' : 'bg-white text-slate-800'}`}>
                        {num ?? '★'}
                    </div>
                ))}
            </div>
        ));
    };

    return (
        <div className="min-h-screen bg-slate-950 text-white flex flex-col">
            {/* Header */}
            <div className="grid grid-cols-3 gap-3 p-4 bg-indigo-900/40">
                <div className="bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg">
                    <span className="text-[10px] font-bold text-indigo-400 uppercase tracking-tight">Room</span>
                    <span className="text-lg font-black">{roomId ?? '...'}</span>
                </div>
                <div className="bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg">
                    <span className="text-[10px] font-bold text-indigo-400 uppercase tracking-tight">Stake</span>
                    <span className="text-lg font-black">{wager}</span>
                </div>
                <div className="bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg border-2 border-indigo-500">
                    <span className="text-[10px] font-bold text-indigo-400 uppercase tracking-tight">Starts In</span>
                    <span className={`text-lg font-black ${countdown < 10 ? 'text-red-600 animate-pulse' : 'text-indigo-600'}`}>
                        {countdown}s
                    </span>
                </div>
            </div>

            <div className="flex-1 p-4 overflow-y-auto">
                {isReady ? (
                    <div className="flex flex-col items-center justify-center h-64 text-center space-y-4">
                        <div className="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center animate-bounce shadow-lg shadow-green-500/50">
                            <svg className="w-10 h-10 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                            </svg>
                        </div>
                        <h2 className="text-2xl font-black italic">YOU ARE IN!</h2>
                        <p className="text-slate-400 text-sm">Waiting for the round to begin...</p>
                    </div>
                ) : (
                    <>
                        <div className="text-center mb-4">
                            <p className="text-slate-400 text-xs uppercase font-bold tracking-widest">Select cards to join the game</p>
                        </div>
                        <div className="grid grid-cols-10 gap-1.5 max-w-xl mx-auto mb-8">
                            {Array.from({ length: 100 }, (_, i) => i + 1).map(id => {
                                const isMine = myCards.some((c: MasterCard) => getCardId(c) === id);
                                const isTaken = lockedCards.includes(id);
                                return (
                                    <button
                                        key={id}
                                        disabled={isTaken || countdown <= 0 || isReady}
                                        onClick={() => handleToggleCard(id)}
                                        className={`aspect-square flex items-center justify-center text-[10px] font-bold rounded transition-all 
                                            ${isMine ? 'bg-orange-500 scale-110 shadow-lg' : isTaken ? 'bg-slate-800 opacity-30 cursor-not-allowed' : 'bg-indigo-500/20 hover:bg-indigo-500/40'}`}
                                    >
                                        {id}
                                    </button>
                                );
                            })}
                        </div>
                    </>
                )}

                {/* Card Previews */}
                <div className={`flex gap-4 justify-center max-w-4xl mx-auto pb-24 transition-opacity ${isReady ? 'opacity-100' : 'opacity-80'}`}>
                    {[0, 1].map(index => (
                        <div key={index} className="flex-1 max-w-[200px]">
                            {myCards[index] ? (
                                <div className="relative bg-[#fefce8] p-3 rounded-xl shadow-2xl">
                                    {!isReady && (
                                        <button
                                            onClick={() => handleToggleCard(getCardId(myCards[index]))}
                                            className="absolute -top-2 -right-2 bg-red-500 text-white w-6 h-6 rounded-full font-bold shadow-lg flex items-center justify-center z-20">×</button>
                                    )}
                                    <div className="grid grid-cols-5 text-center font-black text-[10px] mb-1">
                                        <span className="text-orange-600">B</span><span className="text-green-600">I</span>
                                        <span className="text-blue-600">N</span><span className="text-red-600">G</span>
                                        <span className="text-purple-600">O</span>
                                    </div>
                                    {renderCardGrid(getNumbers(myCards[index]))}
                                </div>
                            ) : !isReady && (
                                <div className="h-44 border-2 border-dashed border-slate-700 rounded-xl bg-slate-900/50 flex flex-col items-center justify-center text-slate-600 p-4 text-[10px] font-bold uppercase">
                                    Empty Slot
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            </div>

            {/* Bottom Controls */}
            <div className="fixed bottom-0 left-0 right-0 p-4 grid grid-cols-2 gap-4 bg-slate-900/90 backdrop-blur-md border-t border-white/10 z-30">
                <button onClick={onBack} className="bg-slate-800 py-3 rounded-xl font-bold text-sm tracking-wide">LEAVE</button>

                {isReady ? (
                    <div className="bg-green-600/20 border border-green-500/50 text-green-500 py-3 rounded-xl font-black text-sm text-center flex items-center justify-center space-x-2">
                        <span className="animate-pulse">●</span>
                        <span>READY</span>
                    </div>
                ) : (
                    <button
                        onClick={handleConfirmJoin}
                        disabled={myCards.length === 0 || isJoining}
                        className={`py-3 rounded-xl font-black text-sm tracking-wide transition-all ${myCards.length > 0 ? 'bg-orange-500 shadow-lg shadow-orange-500/50 text-white' : 'bg-slate-800 text-slate-600 cursor-not-allowed'
                            }`}>
                        {isJoining ? 'JOINING...' : 'JOIN GAME'}
                    </button>
                )}
            </div>
        </div>
    );
};