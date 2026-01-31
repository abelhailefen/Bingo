import { useEffect, useRef, useState, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import * as signalR from '@microsoft/signalr';
import {
    joinAutoLobby,
    selectCardLock,
    getTakenCards,
    getMyCards,
    leaveLobby,
    purchaseCards,
    getUser,
    getMasterCard
} from '../services/api';
import {
    setLobbyData,
    updateMyCards,
    updateLockedCards,
    syncLockedCards,
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
    const isTransitioningToGame = useRef(false);

    const [countdown, setCountdown] = useState<number>(0);
    const [scheduledStartTime, setScheduledStartTime] = useState<string | null>(null);
    const [isProcessing, setIsProcessing] = useState(false);
    const [cardPage, setCardPage] = useState<number>(0);
    const [serverMessage, setServerMessage] = useState<string | null>(null);
    
    // NEW STATE
    const [selectedIds, setSelectedIds] = useState<number[]>([]);
    const [previewCards, setPreviewCards] = useState<Record<number, MasterCard>>({});
    const [userBalance, setUserBalance] = useState<number | null>(null);

    const { roomId, lockedCards } = useSelector((state: RootState) => state.game);

    useEffect(() => {
        roomIdRef.current = roomId;
    }, [roomId]);

    // Fetch Balance
    useEffect(() => {
        getUser(userId).then(res => {
            if (!res.isFailed && res.data) {
                setUserBalance(res.data.balance);
            }
        });
    }, [userId]);

    const getCardId = (obj: MasterCard | any): number => {
        if (!obj) return 0;
        return obj.masterCardId ?? obj.MasterCardId ?? obj.id ?? obj.Id ?? 0;
    };

    const refreshMyCards = async (rId: number) => {
        // Only for REJOINING or if we persist. 
        // With new flow, myCards might be empty until game starts or after purchase.
        try {
            const myCardsRes = await getMyCards(rId, userId);
            if (myCardsRes.data) {
                const normalized: MasterCard[] = myCardsRes.data.map((c: any) => c.masterCard || c.MasterCard || c);
                dispatch(updateMyCards(normalized));
                return normalized;
            }
        } catch (err) {
            console.error("Refresh Cards Error:", err);
        }
        return [];
    };

    const startSignalR = async (rId: number) => {
        if (connectionRef.current) {
            await connectionRef.current.stop();
            connectionRef.current = null;
        }

        const connection = new signalR.HubConnectionBuilder()
            .withUrl("/bingohub")
            .withAutomaticReconnect()
            .build();

        connection.on("CardSelectionChanged", (cardId: number, isLocked: boolean, senderId: number) => {
            if (senderId === userId) return;
            dispatch(syncLockedCards({ cardId: Number(cardId), isLocked }));
        });

        connection.on("WaitingForPreviousGame", (waitingRoomId: number) => {
            if (Number(waitingRoomId) === roomIdRef.current) {
                setServerMessage("Waiting for previous game to finish...");
            }
        });

        connection.on("GameStarted", (startedRoomId: number) => {
            if (Number(startedRoomId) === roomIdRef.current) {
                // If game starts, we might want to auto-move if we purchased? 
                // Or if we haven't purchased, we missed the boat.
                 initLobby();
            }
        });

        try {
            await connection.start();
            await connection.invoke("JoinRoomGroup", rId.toString());
            connectionRef.current = connection;
        } catch (err) {
            console.error("SignalR Connection Error:", err);
        }
    };

    const initLobby = useCallback(async () => {
        try {
            setIsProcessing(false);
            setServerMessage(null);
            setSelectedIds([]); // Reset selection

            dispatch(setLobbyData({ roomId: null, wager: wager }));
            dispatch(updateMyCards([]));
            dispatch(updateLockedCards([]));

            const res = await joinAutoLobby(userId, wager);

            if (res?.data) {
                const rId = res.data.roomId;
                setScheduledStartTime(res.data.scheduledStartTime);
                dispatch(setLobbyData({ roomId: rId, wager }));

                // Load existing cards (rejoin scenario)
                const existing = await refreshMyCards(rId);
                 if (existing.length > 0) {
                     // If user already has cards (purchased), pre-select them or just show them?
                     // For now, let's assume they are "Selected"
                     setSelectedIds(existing.map(c => getCardId(c)));
                 }

                const takenRes = await getTakenCards(rId);
                if (takenRes.data) {
                    dispatch(updateLockedCards(takenRes.data.map(Number)));
                }

                startSignalR(rId);
            }
        } catch (err) {
            console.error("Lobby Init Failed:", err);
        }
    }, [userId, wager, dispatch]);

    useEffect(() => {
        initLobby();
        return () => {
            if (roomIdRef.current && !isTransitioningToGame.current) {
                leaveLobby(roomIdRef.current, userId).catch(console.error);
            }
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
                setTimeout(() => {
                    if (!isTransitioningToGame.current) initLobby();
                }, 3000);
            }
        }, 1000);

        return () => clearInterval(interval);
    }, [scheduledStartTime, initLobby]);

    const handleToggleCard = async (cardId: number) => {
        if (!roomId || countdown <= 1) return;
        
        // Local Logic
        const isSelected = selectedIds.includes(cardId);
        let newSelection = [...selectedIds];

        if (isSelected) {
            newSelection = newSelection.filter(id => id !== cardId);
            // Remove from previewCards if deselected
            setPreviewCards(prev => {
                const newPrev = { ...prev };
                delete newPrev[cardId];
                return newPrev;
            });
        } else {
            if (newSelection.length >= 2) {
                // Auto deselect first? Or strict limit?
                // Strict limit for now
                alert("You can only select up to 2 cards.");
                return;
            }
            newSelection.push(cardId);
            
            // Fetch preview data if needed
            if (!previewCards[cardId]) {
                 getMasterCard(roomId, cardId).then(res => {
                     if (res.data) {
                         setPreviewCards(prev => ({ ...prev, [cardId]: res.data }));
                     }
                 });
            }
        }

        setSelectedIds(newSelection);

        // Optional: Broadcast "Looking at" (Soft Lock) 
        // We use selectCardLock but know it doesn't persist DB anymore
        try {
            await selectCardLock(roomId, cardId, !isSelected, userId);
        } catch (err) {
            console.error("Card Toggle Error:", err);
        }
    };

    const handleConfirmJoin = async () => {
        if (!roomId) return;
        
        if (selectedIds.length === 0) {
            alert("Please select at least one card first.");
            return;
        }

        // Balance Check Client Side
        const totalCost = selectedIds.length * wager;
        if (userBalance !== null && userBalance < totalCost) {
            alert(`Insufficient Balance! You need ${totalCost.toFixed(2)} Birr but have ${userBalance.toFixed(2)} Birr.`);
            return;
        }

        setIsProcessing(true);

        try {
            const res = await purchaseCards(userId, roomId, selectedIds);
            
            if (!res.isFailed) {
                // Success!
                isTransitioningToGame.current = true;
                onEnterGame(roomId);
            } else {
                alert(res.message || "Purchase failed. Please try again.");
                // Refresh taken cards as maybe someone took it
                const takenRes = await getTakenCards(roomId);
                if (takenRes.data) dispatch(updateLockedCards(takenRes.data.map(Number)));
            }
        } catch (error: any) {
            console.error(error);
            const errorMsg = error.response?.data?.message || "An error occurred during purchase.";
            alert(errorMsg);
        } finally {
            setIsProcessing(false);
        }
    };
    
    // Helper for grid rendering
    const getNumbers = (obj: MasterCard | any): any[] => {
        return obj?.numbers ?? obj?.Numbers ?? [];
    };

    return (
        <div className="min-h-screen bg-[#0f172a] text-white flex flex-col">
            {/* Header Stats */}
            <div className="grid grid-cols-4 gap-2 p-4 bg-indigo-900/40 border-b border-white/5">
                <div className="bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg">
                    <span className="text-[10px] font-bold text-indigo-400 uppercase">Room</span>
                    <span className="text-lg font-black">{roomId ?? '--'}</span>
                </div>

                <div className="bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg">
                    <span className="text-[10px] font-bold text-indigo-400 uppercase">Stake</span>
                    <span className="text-lg font-black">{wager}</span>
                </div>
                
                 <div className="bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg">
                    <span className="text-[10px] font-bold text-indigo-400 uppercase">Balance</span>
                     <span className="text-sm font-black text-green-600">
                        {userBalance !== null ? `${userBalance} ETB` : '...'}
                    </span>
                 </div>

                <div className={`bg-white rounded-xl py-2 flex flex-col items-center text-slate-900 shadow-lg border-2 transition-all duration-500 ${serverMessage || countdown < 10 ? 'border-orange-500' : 'border-transparent'}`}>
                    <span className="text-[10px] font-bold text-orange-400 uppercase">
                        {serverMessage ? 'Status' : 'Starts In'}
                    </span>
                    <div className="flex items-center justify-center h-full">
                        {serverMessage ? (
                            <span className="text-[9px] font-black text-orange-600 uppercase text-center leading-none animate-pulse">
                                Waiting for<br />Prev Game
                            </span>
                        ) : (
                            <span className={`text-lg font-black ${countdown < 10 ? 'text-red-600 animate-pulse' : 'text-indigo-600'}`}>
                                {countdown}s
                            </span>
                        )}
                    </div>
                </div>
            </div>

            {/* Selection UI */}
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
                        const isSelected = selectedIds.includes(id);
                        const isTaken = lockedCards.includes(id) && !isSelected; // Taken by others
                        return (
                            <button
                                key={id}
                                disabled={isTaken || countdown <= 1 || isProcessing}
                                onClick={() => handleToggleCard(id)}
                                className={`aspect-square flex items-center justify-center text-[10px] font-bold rounded transition-all 
                                    ${isSelected ? 'bg-orange-500 scale-110 shadow-lg text-white' :
                                        isTaken ? 'bg-slate-800 opacity-20 cursor-not-allowed' :
                                            'bg-indigo-500/10 text-indigo-300'}`}>
                                {id}
                            </button>
                        );
                    })}
                </div>

                {/* Previews */}
                <div className="flex gap-4 justify-center max-w-md mx-auto pb-32">
                    {[0, 1].map(index => {
                        const hasSelection = selectedIds.length > index;
                        const cardId = hasSelection ? selectedIds[index] : null;
                        const cardData = cardId ? previewCards[cardId] : null;
                        
                        return (
                        <div key={index} className="flex-1">
                            {cardId ? (
                                <div className="relative bg-[#fefce8] p-2 rounded-xl shadow-2xl border-b-4 border-black/10">
                                    <button
                                        disabled={countdown <= 1}
                                        onClick={() => handleToggleCard(cardId)}
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
                                                    if (!cardData) {
                                                         return (
                                                            <div key={c} className="h-8 flex items-center justify-center border border-black/5 bg-slate-100 animate-pulse rounded-sm"></div>
                                                         );
                                                    }
                                                    
                                                    const nums = getNumbers(cardData);
                                                    const cell = nums.find(n => (n.positionRow ?? n.PositionRow) === r + 1 && (n.positionCol ?? n.PositionCol) === c + 1);
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
                                     <div className="mt-2 text-center text-[10px] text-slate-400 font-bold uppercase">
                                        {wager} ETB
                                    </div>
                                </div>
                            ) : (
                                <div className="h-40 border-2 border-dashed border-indigo-500/20 rounded-xl bg-indigo-950/20 flex items-center justify-center text-indigo-500/40 text-[10px] font-black uppercase">
                                    Slot {index + 1}
                                </div>
                            )}
                        </div>
                    )})}
                </div>
            </div>

            {/* Actions */}
            <div className="fixed bottom-0 left-0 right-0 p-4 grid grid-cols-2 gap-4 bg-[#0f172a]/95 backdrop-blur-md border-t border-white/10 z-50">
                <button
                    onClick={onBack}
                    className="bg-slate-800 text-white py-4 rounded-2xl font-black text-sm uppercase"
                >
                    LEAVE
                </button>
                <button
                    onClick={handleConfirmJoin}
                    disabled={selectedIds.length === 0 || isProcessing}
                    className={`py-4 rounded-2xl font-black text-sm uppercase transition-all ${selectedIds.length > 0 && !isProcessing
                        ? 'bg-green-600 text-white shadow-lg shadow-green-900/20'
                        : 'bg-slate-800 text-slate-600 cursor-not-allowed'
                        }`}
                >
                    {isProcessing ? 'PROCESSING...' : 
                     selectedIds.length > 0 ? `BUY FOR ${selectedIds.length * wager} BIRR` : 'SELECT CARD'}
                </button>
            </div>
        </div>
    );
};
