import { useEffect, useState } from 'react';
import * as signalR from '@microsoft/signalr';
import { joinAutoLobby, selectCardLock } from '../services/api'; 

export const Lobby = ({ userId, onRoomEntered }: any) => {
    const [roomId, setRoomId] = useState<number | null>(null);
    const [lockedCards, setLockedCards] = useState<number[]>([]); // Cards locked by OTHERS
    const [mySelection, setMySelection] = useState<number[]>([]);

    useEffect(() => {
        const enterLobby = async () => {
            try {
                const res = await joinAutoLobby(userId);
                // Check if the API returned a failure field 
                // (based on your ApiResponse type)
                if (res && !res.isFailed) {
                    setRoomId(res.data.roomId);
                    setupSignalR(res.data.roomId);
                }
            } catch (error) {
                console.error("Failed to join lobby:", error);
                // Optional: Set an error state to show the user
            }
        };

        if (userId) {
            enterLobby();
        }
    }, [userId]); // Add userId as dependency

    const setupSignalR = async (rId: number) => {
        const connection = new signalR.HubConnectionBuilder()
            // If your React app is on a different port than the API (53032), 
            // use the full URL here:
            .withUrl("https://localhost:53032/bingohub", {
                skipNegotiation: false,
                transport: signalR.HttpTransportType.WebSockets | signalR.HttpTransportType.LongPolling
            })
            .withAutomaticReconnect()
            .build();

        try {
            await connection.start();
            console.log("Connected to SignalR!");

            // Match the method name exactly as it appears in C#
            await connection.invoke("JoinRoomGroup", rId.toString());

            connection.on("CardSelectionChanged", (cardId: number, isLocked: boolean, senderId: number) => {
                if (senderId === userId) return;
                setLockedCards(prev => isLocked
                    ? [...new Set([...prev, cardId])]
                    : prev.filter(id => id !== cardId)
                );
            });
        } catch (err) {
            console.error("SignalR Connection Failed: ", err);
        }
    };

    const handleToggleCard = async (cardId: number) => {
        if (lockedCards.includes(cardId)) return; // Can't click if locked by others

        const isSelecting = !mySelection.includes(cardId);
        
        // Notify others immediately via SignalR endpoint
        await selectCardLock(roomId!, cardId, isSelecting);

        if (isSelecting) {
            if (mySelection.length >= 2) return;
            setMySelection([...mySelection, cardId]);
        } else {
            setMySelection(mySelection.filter(id => id !== cardId));
        }
    };

    return (
        <div className="grid grid-cols-10 gap-2">
            {Array.from({ length: 100 }, (_, i) => i + 1).map(id => {
                const isLockedByOther = lockedCards.includes(id);
                const isSelectedByMe = mySelection.includes(id);

                return (
                    <button
                        key={id}
                        disabled={isLockedByOther}
                        onClick={() => handleToggleCard(id)}
                        className={`p-2 rounded ${
                            isSelectedByMe ? 'bg-orange-500' : 
                            isLockedByOther ? 'bg-gray-700 opacity-50 cursor-not-allowed' : 'bg-indigo-500'
                        }`}
                    >
                        {id}
                    </button>
                );
            })}
        </div>
    );
};