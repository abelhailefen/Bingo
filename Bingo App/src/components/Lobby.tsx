import { useEffect, useRef, useState, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import * as signalR from '@microsoft/signalr';
import {
    joinAutoLobby,
    selectCardLock,
    getTakenCards,
    getMyCards,
    leaveLobby // Fix: Used in cleanup
} from '../services/api';
import {
    setLobbyData,
    updateMyCards,
    updateLockedCards,
    syncLockedCards,
} from '../store/gameSlice';
import type { RootState, AppDispatch } from '../store';
import type { MasterCard } from '../types/gameplay'; // Fix: Used for typing

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
    const [isJoining, setIsJoining] = useState(false); 
    const [cardPage, setCardPage] = useState<number>(0);
    const isTransitioningToGame = useRef(false);
    const [serverMessage, setServerMessage] = useState<string | null>(null);

    const { roomId, myCards, lockedCards } = useSelector((state: RootState) => state.game);

    useEffect(() => {
        roomIdRef.current = roomId;
    }, [roomId]);

    const getCardId = (obj: MasterCard | any): number => {
        if (!obj) return 0;
        return obj.masterCardId ?? obj.MasterCardId ?? obj.id ?? obj.Id ?? 0;
    };

    const getNumbers = (obj: MasterCard | any): any[] => {
        return obj.numbers ?? obj.Numbers ?? [];
    };

    const refreshMyCards = async (rId: number) => {
        const myCardsRes = await getMyCards(rId, userId);
        if (myCardsRes.data) {
            const normalized: MasterCard[] = myCardsRes.data.map((c: any) => c.masterCard || c.MasterCard || c);
            dispatch(updateMyCards(normalized));
            return normalized;
        }
        return [];
    };

    const startSignalR = async (rId: number) => {
        // 1. Clean up any existing connection
        if (connectionRef.current) {
            await connectionRef.current.stop();
            connectionRef.current = null;
        }

        const connection = new signalR.HubConnectionBuilder()
            .withUrl("/bingohub")
            .withAutomaticReconnect()
            .build();

        // Event: Another player picked/dropped a card
        connection.on("CardSelectionChanged", (cardId: number, isLocked: boolean, senderId: number) => {
            if (senderId === userId) return;
            dispatch(syncLockedCards({ cardId: Number(cardId), isLocked }));
        });

        // Event: The BackgroundService pushed the start time because a game is still running
        connection.on("WaitingForPreviousGame", (waitingRoomId: number) => {
            if (Number(waitingRoomId) === roomIdRef.current) {
                setServerMessage("Waiting for previous game to finish...");
                // Optionally clear message after a few seconds
                setTimeout(() => setServerMessage(null), 8000);
            }
        });

        // Event: The game is officially starting!
        connection.on("GameStarted", (startedRoomId: number) => {
            if (Number(startedRoomId) === roomIdRef.current) {
                console.log("Game is starting, transitioning...");

                // Prevent the 'leaveLobby' logic in useEffect cleanup from firing
                isTransitioningToGame.current = true;

                // Trigger the navigation to the Game screen
                onEnterGame(Number(startedRoomId));
            }
        });

        try {
            await connection.start();
            // Join the specific room group so we only get events for this lobby
            await connection.invoke("JoinRoomGroup", rId.toString());
            connectionRef.current = connection;
            console.log(`SignalR connected to room ${rId}`);
        } catch (err) {
            console.error("SignalR Lobby Error:", err);
        }
    };

    const initLobby = useCallback(async () => {
        try {
            const res = await joinAutoLobby(userId, wager);
            if (res?.data) {
                const rId = res.data.roomId;
                setScheduledStartTime(res.data.scheduledStartTime);
                dispatch(setLobbyData({ roomId: rId, wager }));

                await refreshMyCards(rId);

                const takenRes = await getTakenCards(rId);
                if (takenRes.data) {
                    dispatch(updateLockedCards(takenRes.data.map(Number)));
                }
                startSignalR(rId);
            }
        } catch (err) { console.error("Init Lobby Error:", err); }
    }, [userId, wager, dispatch]);

    useEffect(() => {
        initLobby();
        return () => {
            // Only leave lobby if we are NOT transitioning to the game
            if (roomIdRef.current && !isTransitioningToGame.current) {
                leaveLobby(roomIdRef.current, userId).catch(console.error);
            }

            // We still want to stop SignalR regardless
            if (connectionRef.current) connectionRef.current.stop();
        };
    }, [initLobby, userId]);

    useEffect(() => {
        if (!scheduledStartTime) return;
        const interval = setInterval(() => {
            const now = new Date().getTime();
            const start = new Date(scheduledStartTime).getTime();
            const diff = Math.max(0, Math.floor((start - now) / 1000));
            setCountdown(diff);
            if (diff <= 0) {
                clearInterval(interval);
                initLobby();
            }
        }, 1000);
        return () => clearInterval(interval);
    }, [scheduledStartTime, initLobby]);

    const handleToggleCard = async (cardId: number) => {
        if (!roomId || countdown <= 1) return;
        const isMine = myCards.some((c) => getCardId(c) === cardId);
        try {
            if (!isMine && myCards.length >= 2) {
                const firstCardId = getCardId(myCards[0]);
                await selectCardLock(roomId, firstCardId, false, userId);
            }
            const res = await selectCardLock(roomId, cardId, !isMine, userId);
            if (res && !res.isFailed) {
                await refreshMyCards(roomId);
            }
        } catch (err) { console.error(err); }
    };
    const handleConfirmJoin = async () => {
        if (!roomId) return;
        setIsJoining(true);

        try {
            const currentCards = await refreshMyCards(roomId);
            if (currentCards.length === 0) {
                alert("Please select at least one card first.");
                setIsJoining(false);
                return;
            }

            // SET THIS TO TRUE HERE
            isTransitioningToGame.current = true;

            onEnterGame(roomId);
        } catch (error) {
            console.error(error);
            setIsJoining(false);
        }
    };
    return (
        <div className="min-h-screen bg-[#0f172a] text-white flex flex-col">
            <div className="grid grid-cols-3 gap-3 p-4 bg-indigo-900/40 border-b border-white/5">
                {/* Room ID Box */}
                <div className="bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg">
                    <span className="text-[10px] font-bold text-indigo-400 uppercase tracking-tighter">Room</span>
                    <span className="text-lg font-black">{roomId ?? '--'}</span>
                </div>

                {/* Stake Box */}
                <div className="bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg">
                    <span className="text-[10px] font-bold text-indigo-400 uppercase tracking-tighter">Stake</span>
                    <span className="text-lg font-black">{wager}</span>
                </div>

                {/* Dynamic Status/Countdown Box */}
                <div className={`bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg border-2 transition-all duration-500 ${serverMessage || countdown < 10 ? 'border-orange-500' : 'border-transparent'
                    }`}>
                    <span className="text-[10px] font-bold text-orange-400 uppercase tracking-tighter">
                        {serverMessage ? 'Status' : 'Starts In'}
                    </span>

                    <div className="flex items-center justify-center h-full">
                        {serverMessage ? (
                            /* Show this when the RoomManagerService says a previous game is busy */
                            <div className="flex flex-col items-center leading-none animate-pulse">
                                <span className="text-[9px] font-black text-orange-600 uppercase text-center">
                                    Waiting for
                                </span>
                                <span className="text-[9px] font-black text-orange-600 uppercase text-center">
                                    Prev Game
                                </span>
                            </div>
                        ) : (
                            /* Standard Countdown display */
                            <span className={`text-lg font-black transition-colors ${countdown < 10 ? 'text-red-600 animate-pulse' : 'text-indigo-600'
                                }`}>
                                {countdown}s
                            </span>
                        )}
                    </div>
                </div>
            </div>

            <div className="flex-1 p-4 overflow-y-auto">
                <div className="flex justify-center gap-2 mb-4">
                    {[0, 1].map(p => (
                        <button key={p} onClick={() => setCardPage(p)}
                            className={`px-6 py-2 rounded-full text-[10px] font-black transition-all ${cardPage === p ? 'bg-orange-500 text-white shadow-lg' : 'bg-indigo-950 text-indigo-400 border border-white/10'}`}>
                            {p === 0 ? '1 - 100' : '101 - 200'}
                        </button>
                    ))}
                </div>

                <div className="grid grid-cols-10 gap-1.5 max-w-sm mx-auto mb-8 bg-indigo-950/30 p-2 rounded-xl border border-white/5">
                    {Array.from({ length: 100 }, (_, i) => (cardPage * 100) + i + 1).map(id => {
                        const isMine = myCards.some((c) => getCardId(c) === id);
                        const isTaken = lockedCards.includes(id);
                        return (
                            <button key={id} disabled={isTaken && !isMine} onClick={() => handleToggleCard(id)}
                                className={`aspect-square flex items-center justify-center text-[10px] font-bold rounded transition-all 
                                    ${isMine ? 'bg-orange-500 scale-110 shadow-lg text-white' :
                                        isTaken ? 'bg-slate-800 opacity-20 cursor-not-allowed' :
                                            'bg-indigo-500/10 text-indigo-300'}`}>
                                {id}
                            </button>
                        );
                    })}
                </div>

                <div className="flex gap-4 justify-center max-w-md mx-auto pb-32">
                    {[0, 1].map(index => (
                        <div key={index} className="flex-1">
                            {myCards[index] ? (
                                <div className="relative bg-[#fefce8] p-2 rounded-xl shadow-2xl border-b-4 border-black/10">
                                    <button onClick={() => handleToggleCard(getCardId(myCards[index]))}
                                        className="absolute -top-2 -right-2 bg-red-500 text-white w-6 h-6 rounded-full font-bold shadow-lg flex items-center justify-center z-20">×</button>
                                    <div className="grid grid-cols-5 text-center font-black text-[9px] mb-1">
                                        <span className="text-orange-600">B</span><span className="text-green-600">I</span>
                                        <span className="text-blue-600">N</span><span className="text-red-600">G</span>
                                        <span className="text-purple-600">O</span>
                                    </div>
                                    <div className="space-y-0.5">
                                        {Array(5).fill(0).map((_, r) => (
                                            <div key={r} className="grid grid-cols-5 gap-0.5">
                                                {Array(5).fill(0).map((_, c) => {
                                                    const cell = getNumbers(myCards[index]).find(n => (n.positionRow ?? n.PositionRow) === r + 1 && (n.positionCol ?? n.PositionCol) === c + 1);
                                                    const val = cell?.number ?? cell?.Number;
                                                    return (
                                                        <div key={c} className={`h-8 flex items-center justify-center border border-black/5 text-[10px] font-bold rounded-sm ${val === null ? 'bg-green-500 text-white' : 'bg-white text-slate-800'}`}>
                                                            {val ?? '★'}
                                                        </div>
                                                    );
                                                })}
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            ) : (
                                <div className="h-40 border-2 border-dashed border-indigo-500/20 rounded-xl bg-indigo-950/20 flex items-center justify-center text-indigo-500/40 text-[10px] font-black uppercase">
                                    Slot {index + 1}
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            </div>

            <div className="fixed bottom-0 left-0 right-0 p-4 grid grid-cols-2 gap-4 bg-[#0f172a]/95 backdrop-blur-md border-t border-white/10 z-50">
                <button onClick={onBack} className="bg-slate-800 py-4 rounded-2xl font-black text-sm uppercase">LEAVE</button>
                <button
                    onClick={handleConfirmJoin}
                    disabled={myCards.length === 0 || isJoining}
                    className={`py-4 rounded-2xl font-black text-sm uppercase transition-all ${myCards.length > 0 && !isJoining
                            ? 'bg-orange-600 text-white shadow-lg'
                            : 'bg-slate-800 text-slate-600 cursor-not-allowed'
                        }`}
                >
                    {isJoining ? 'JOINING...' : 'JOIN GAME'}
                </button>
            </div>
        </div>
    );
};