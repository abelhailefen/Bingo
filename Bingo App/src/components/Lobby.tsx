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
    const [isJoining, setIsJoining] = useState(false);

    // NEW: State for card range pagination (0 for 1-100, 1 for 101-200)
    const [cardPage, setCardPage] = useState<number>(0);

    const { roomId, myCards, lockedCards } = useSelector((state: RootState) => state.game);

    useEffect(() => {
        roomIdRef.current = roomId;
    }, [roomId]);

    const getCardId = (obj: MasterCard | null): number => {
        if (!obj) return 0;
        return (obj as any).masterCardId ?? (obj as any).MasterCardId ?? 0;
    };

    const getNumbers = (obj: MasterCard): any[] => {
        return (obj as any).numbers ?? (obj as any).Numbers ?? [];
    };

    const startSignalR = async (rId: number) => {
        if (connectionRef.current) {
            await connectionRef.current.stop();
        }

        const connection = new signalR.HubConnectionBuilder()
            .withUrl("/bingohub")
            .withAutomaticReconnect()
            .build();

        connection.on("CardSelectionChanged", (cardId: number, isLocked: boolean, senderId: number) => {
            if (senderId === userId) return;
            dispatch(syncLockedCards({ cardId: Number(cardId), isLocked }));
        });

        connection.on("GameStarted", (startedRoomId: number) => {
            console.log(`Room ${startedRoomId} started. Fetching new lobby...`);
            initLobby();
        });

        try {
            await connection.start();
            await connection.invoke("JoinRoomGroup", rId.toString());
            connectionRef.current = connection;
        } catch (err) { console.error(err); }
    };

    const initLobby = useCallback(async () => {
        try {
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
                } else {
                    dispatch(updateMyCards([]));
                }

                if (takenRes.data) {
                    const myIds = myCardsRes.data?.map((c: any) => getCardId(c.masterCard || c.MasterCard)) || [];
                    const othersTaken = takenRes.data.filter((id: any) => !myIds.includes(Number(id)));
                    dispatch(updateLockedCards(othersTaken.map(Number)));
                }
                startSignalR(rId);
            }
        } catch (err) { console.error(err); }
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

        const isMine = myCards.some((c: MasterCard) => getCardId(c) === cardId);
        try {
            if (!isMine && myCards.length >= 2) {
                const secondCardId = getCardId(myCards[1]);
                await selectCardLock(roomId, secondCardId, false, userId);
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
        if (!roomId || countdown <= 0) return;
        setIsJoining(true);
        setTimeout(() => {
            setIsJoining(false);
            onEnterGame(roomId);
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
                    <div key={cIdx} className={`h-8 flex items-center justify-center border border-black/5 text-[10px] font-bold rounded-sm ${num === null ? 'bg-green-500 text-white' : 'bg-white text-slate-800'}`}>
                        {num ?? '★'}
                    </div>
                ))}
            </div>
        ));
    };

    return (
        <div className="min-h-screen bg-[#0f172a] text-white flex flex-col">
            {/* Header */}
            <div className="grid grid-cols-3 gap-3 p-4 bg-indigo-900/40 border-b border-white/5">
                <div className="bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg">
                    <span className="text-[10px] font-bold text-indigo-400 uppercase">Room</span>
                    <span className="text-lg font-black">{roomId ?? '--'}</span>
                </div>
                <div className="bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg">
                    <span className="text-[10px] font-bold text-indigo-400 uppercase">Stake</span>
                    <span className="text-lg font-black">{wager}</span>
                </div>
                <div className="bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg border-2 border-orange-500">
                    <span className="text-[10px] font-bold text-orange-400 uppercase tracking-tight">Starts In</span>
                    <span className={`text-lg font-black ${countdown < 10 ? 'text-red-600 animate-pulse' : 'text-indigo-600'}`}>
                        {countdown}s
                    </span>
                </div>
            </div>

            <div className="flex-1 p-4 overflow-y-auto">
                <div className="text-center mb-4">
                    <p className="text-indigo-400 text-xs uppercase font-black tracking-[0.2em] mb-4">Select cards to join the game</p>

                    {/* Range Selector Tabs */}
                    <div className="flex justify-center gap-2 mb-2">
                        <button
                            onClick={() => setCardPage(0)}
                            className={`px-4 py-2 rounded-full text-[10px] font-black transition-all ${cardPage === 0 ? 'bg-orange-500 text-white shadow-lg shadow-orange-500/20' : 'bg-indigo-950/50 text-indigo-400 border border-white/5'}`}
                        >
                            1 - 100
                        </button>
                        <button
                            onClick={() => setCardPage(1)}
                            className={`px-4 py-2 rounded-full text-[10px] font-black transition-all ${cardPage === 1 ? 'bg-orange-500 text-white shadow-lg shadow-orange-500/20' : 'bg-indigo-950/50 text-indigo-400 border border-white/5'}`}
                        >
                            101 - 200
                        </button>
                    </div>
                </div>

                {/* Card Selection Grid */}
                <div className="grid grid-cols-10 gap-1.5 max-w-sm mx-auto mb-8 bg-indigo-950/30 p-2 rounded-xl border border-white/5">
                    {Array.from({ length: 100 }, (_, i) => (cardPage * 100) + i + 1).map(id => {
                        const isMine = myCards.some((c: MasterCard) => getCardId(c) === id);
                        const isTaken = lockedCards.includes(id);
                        return (
                            <button
                                key={id}
                                disabled={isTaken || countdown <= 0}
                                onClick={() => handleToggleCard(id)}
                                className={`aspect-square flex items-center justify-center text-[10px] font-bold rounded transition-all 
                                    ${isMine ? 'bg-orange-500 scale-110 shadow-lg text-white' :
                                        isTaken ? 'bg-slate-800 opacity-20 cursor-not-allowed' :
                                            'bg-indigo-500/10 hover:bg-indigo-500/30 text-indigo-300'}`}
                            >
                                {id}
                            </button>
                        );
                    })}
                </div>

                {/* Card Previews */}
                <div className="flex gap-4 justify-center max-w-md mx-auto pb-32">
                    {[0, 1].map(index => (
                        <div key={index} className="flex-1">
                            {myCards[index] ? (
                                <div className="relative bg-[#fefce8] p-2 rounded-xl shadow-2xl border-b-4 border-black/10">
                                    <button
                                        onClick={() => handleToggleCard(getCardId(myCards[index]))}
                                        className="absolute -top-2 -right-2 bg-red-500 text-white w-6 h-6 rounded-full font-bold shadow-lg flex items-center justify-center z-20">×</button>
                                    <div className="grid grid-cols-5 text-center font-black text-[9px] mb-1">
                                        <span className="text-orange-600">B</span><span className="text-green-600">I</span>
                                        <span className="text-blue-600">N</span><span className="text-red-600">G</span>
                                        <span className="text-purple-600">O</span>
                                    </div>
                                    {renderCardGrid(getNumbers(myCards[index]))}
                                </div>
                            ) : (
                                <div className="h-40 border-2 border-dashed border-indigo-500/20 rounded-xl bg-indigo-950/20 flex flex-col items-center justify-center text-indigo-500/40 p-4 text-[10px] font-black uppercase text-center">
                                    Empty Slot
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            </div>

            {/* Bottom Controls */}
            <div className="fixed bottom-0 left-0 right-0 p-4 grid grid-cols-2 gap-4 bg-[#0f172a]/95 backdrop-blur-md border-t border-white/10 z-50">
                <button onClick={onBack} className="bg-slate-800 py-4 rounded-2xl font-black text-sm uppercase tracking-widest">LEAVE</button>
                <button
                    onClick={handleConfirmJoin}
                    disabled={myCards.length === 0 || isJoining}
                    className={`py-4 rounded-2xl font-black text-sm uppercase tracking-widest transition-all ${myCards.length > 0 ? 'bg-orange-600 shadow-lg shadow-orange-500/40 text-white' : 'bg-slate-800 text-slate-600 cursor-not-allowed'
                        }`}>
                    {isJoining ? 'JOINING...' : 'JOIN GAME'}
                </button>
            </div>
        </div>
    );
};