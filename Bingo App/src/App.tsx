import { useState, useEffect } from 'react';
import { Lobby } from './components/Lobby';
import { GameRoom } from './components/GameRoom';
import { WagerSelection } from './components/WagerSelection';
import { telegramInit } from './services/api';

/**
 * Main Application Component
 * Manages authentication, wager selection, and navigation
 */
const App = () => {
    // Navigation State: auth -> wager -> lobby -> game
    const [view, setView] = useState<'auth' | 'wager' | 'lobby' | 'game'>('auth');
    
    // User State
    const [userId, setUserId] = useState<number | null>(null);
    const [_authToken, setAuthToken] = useState<string | null>(null);
    const [_wager, setWager] = useState<number | null>(null);
    
    // Room State
    const [activeRoomId, setActiveRoomId] = useState<number | null>(null);

    /**
     * Initialize Telegram Authentication
     */
    useEffect(() => {
        const initTelegramAuth = async () => {
            // Check if running in Telegram WebApp
            if (window.Telegram?.WebApp) {
                const telegram = window.Telegram.WebApp;
                telegram.ready();
                telegram.expand();
                
                const initData = telegram.initData;
                
                if (initData) {
                    try {
                        const response = await telegramInit(initData);
                        
                        if (response.success && response.data) {
                            setAuthToken(response.data);
                            localStorage.setItem('bingo_token', response.data);
                            
                            // Extract userId from token (in your case it's Token_For_{userId})
                            const userIdMatch = response.data.match(/Token_For_(\d+)/);
                            if (userIdMatch) {
                                const id = parseInt(userIdMatch[1]);
                                setUserId(id);
                            }
                            
                            // Move to wager selection
                            setView('wager');
                        } else {
                            console.error('Auth failed:', response.message);
                            // Fallback to dev mode
                            setUserId(123);
                            setView('wager');
                        }
                    } catch (error) {
                        console.error('Telegram init error:', error);
                        // Fallback to dev mode
                        setUserId(123);
                        setView('wager');
                    }
                } else {
                    // No initData - development mode
                    console.log('Running in dev mode (no Telegram initData)');
                    setUserId(123);
                    setView('wager');
                }
            } else {
                // Not in Telegram - development mode
                console.log('Running in dev mode (not in Telegram)');
                setUserId(123);
                setView('wager');
            }
        };

        initTelegramAuth();
    }, []);

    /**
     * Handle wager selection
     */
    const handleWagerSelected = (selectedWager: number) => {
        console.log(`User selected wager: ${selectedWager} birr`);
        setWager(selectedWager);
        setView('lobby');
    };

    /**
     * Transition from Lobby to Active Game
     */
    const handleEnterGame = (roomId: number) => {
        console.log(`Entering Game Room: ${roomId}`);
        setActiveRoomId(roomId);
        setView('game');
    };

    /**
     * Transition from Game back to Lobby
     */
    const handleLeaveGame = () => {
        console.log("Returning to Lobby");
        setView('lobby');
        setActiveRoomId(null);
    };

    return (
        <div className="min-h-screen bg-slate-950 overflow-x-hidden">
            <main>
                {/* AUTH LOADING */}
                {view === 'auth' && (
                    <div className="min-h-screen flex items-center justify-center">
                        <div className="text-center">
                            <h1 className="text-4xl font-bold text-white mb-4">Bingo</h1>
                            <p className="text-gray-400">Authenticating...</p>
                        </div>
                    </div>
                )}

                {/* WAGER SELECTION */}
                {view === 'wager' && (
                    <WagerSelection onWagerSelected={handleWagerSelected} />
                )}

                {/* LOBBY VIEW */}
                {view === 'lobby' && userId && (
                    <Lobby
                        userId={userId}
                        onEnterGame={handleEnterGame}
                    />
                )}

                {/* GAME ROOM VIEW */}
                {view === 'game' && activeRoomId && userId && (
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

export default App;
