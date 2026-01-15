import { useState, useEffect } from 'react';
import { getRooms, createRoom, joinRoom } from '../services/api';
import type { RoomSummary } from '../services/api';

interface LobbyProps {
    userId: number;
    userName: string;
    onRoomEntered: (roomId: number) => void;
}

export const Lobby = ({ userId, userName, onRoomEntered }: LobbyProps) => {
    const [rooms, setRooms] = useState<RoomSummary[]>([]);
    const [loading, setLoading] = useState(false);
    const [creating, setCreating] = useState(false);

    useEffect(() => {
        loadRooms();
    }, []);

    const loadRooms = async () => {
        setLoading(true);
        try {
            const res = await getRooms();
            if (res.isSuccess) {
                setRooms(res.data);
            }
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleCreate = async () => {
        setCreating(true);
        try {
            const res = await createRoom(`${userName}'s Game`, userId);
            if (res.isSuccess) {
                // Auto join created room? Usually yes for host.
                await handleJoin(res.data.roomId);
            } else {
                alert(res.message);
            }
        } catch (err) {
            console.error(err);
            alert("Failed to create room");
        } finally {
            setCreating(false);
        }
    };

    const handleJoin = async (id: number) => {
        try {
            const res = await joinRoom(id, userId);
            if (res.isSuccess) {
                onRoomEntered(id);
            } else {
                alert(res.message);
            }
        } catch (err) {
            console.error(err);
            alert("Failed to join room");
        }
    };

    return (
        <div className="w-full max-w-md flex flex-col gap-6">
            <div className="bg-slate-800 p-6 rounded-2xl shadow-xl">
                <div className="flex justify-between items-center mb-6">
                    <h2 className="text-xl font-bold text-slate-200">Available Rooms</h2>
                    <button
                        onClick={loadRooms}
                        className="text-indigo-400 hover:text-indigo-300 text-sm font-semibold"
                    >
                        Refresh
                    </button>
                </div>

                {loading ? (
                    <div className="text-center py-8 text-slate-500">Loading rooms...</div>
                ) : rooms.length === 0 ? (
                    <div className="text-center py-8 text-slate-500 bg-slate-900/50 rounded-xl">
                        No active rooms found.
                    </div>
                ) : (
                    <div className="flex flex-col gap-3 max-h-[400px] overflow-y-auto">
                        {rooms.map(room => (
                            <div key={room.roomId} className="flex items-center justify-between bg-slate-700/50 p-4 rounded-xl hover:bg-slate-700 transition-colors">
                                <div>
                                    <h3 className="font-bold text-white">{room.name}</h3>
                                    <p className="text-xs text-slate-400">Host: {room.hostName} • Players: {room.playerCount}</p>
                                </div>
                                <button
                                    onClick={() => handleJoin(room.roomId)}
                                    className="bg-indigo-600 hover:bg-indigo-500 px-4 py-2 rounded-lg text-sm font-bold shadow-md transition-all active:scale-95"
                                >
                                    JOIN
                                </button>
                            </div>
                        ))}
                    </div>
                )}
            </div>

            <button
                onClick={handleCreate}
                disabled={creating}
                className="w-full bg-gradient-to-r from-indigo-600 to-violet-600 py-4 rounded-2xl font-bold text-lg shadow-lg hover:shadow-indigo-500/25 transition-all active:scale-95 disabled:opacity-50"
            >
                {creating ? "CREATING..." : "+ CREATE NEW GAME"}
            </button>
        </div>
    );
};
