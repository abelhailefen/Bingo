import { useState } from 'react';
import { Lobby } from './components/Lobby';
import { GameRoom } from './components/GameRoom';

/**
 * Main Application Component
 * Manages the high-level state: Authentication and Navigation (Lobby vs GameRoom)
 */
const App = () => {
    // Navigation State: Determines which screen the user sees
    const [view, setView] = useState<'lobby' | 'game'>('lobby');

    // The Room the user is currently engaged with
    const [activeRoomId, setActiveRoomId] = useState<number | null>(null);

    /** 
     * User ID Logic:
     * In your production app, this will come from telegramInit or devLogin.
     * For now, we use a fixed ID to match your backend testing.
     */
    const [userId] = useState<number>(123);

    /**
     * Transition from Lobby to Active Game
     * Triggered by the "Enter Game" button in Lobby.tsx
     */
    const handleEnterGame = (roomId: number) => {
        console.log(`Entering Game Room: ${roomId}`);
        setActiveRoomId(roomId);
        setView('game');
    };

    /**
     * Transition from Game back to Lobby
     * Triggered by the "Leave" or "Back" button in GameRoom.tsx
     */
    const handleLeaveGame = () => {
        console.log("Returning to Lobby");
        setView('lobby');
        setActiveRoomId(null);
    };

    return (
        // Wrapper with the app's dark slate theme to prevent white flashes
        <div className="min-h-screen bg-slate-950 overflow-x-hidden">
            <main>
                {/* LOBBY VIEW */}
                {view === 'lobby' && (
                    <Lobby
                        userId={userId}
                        onEnterGame={handleEnterGame}
                    />
                )}

                {/* GAME ROOM VIEW */}
                {view === 'game' && activeRoomId && (
                    <GameRoom
                        roomId={activeRoomId}
                        userId={userId}
                        onLeave={handleLeaveGame}
                    />
                )}
            </main>
        </div>
    );
};

// This export fixes the "does not provide an export named default" error
export default App;