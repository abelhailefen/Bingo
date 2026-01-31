import { useState, useEffect } from 'react';
import { Lobby } from './components/Lobby';
import { GameRoom } from './components/GameRoom';
import { WagerSelection } from './components/WagerSelection';
import { telegramInit } from './services/api';

const App = () => {
    const [view, setView] = useState<'auth' | 'wager' | 'lobby' | 'game'>('auth');
    const [userId, setUserId] = useState<number | null>(null);
    const [, setAuthToken] = useState<string | null>(null);
    const [wager, setWager] = useState<number | null>(null);
    const [activeRoomId, setActiveRoomId] = useState<number | null>(null);

    useEffect(() => {
        const initTelegramAuth = async () => {
            const telegram = (window as any).Telegram?.WebApp;

            if (telegram?.initData) {
                telegram.ready();
                telegram.expand();
                try {
                    const response = await telegramInit(telegram.initData);
                    if (response.success && response.data) {
                        setAuthToken(response.data);
                        localStorage.setItem('bingo_token', response.data);
                        // Extracting ID from token or using telegram user object
                        const idMatch = response.data.match(/\d+$/);
                        const id = idMatch ? parseInt(idMatch[0]) : telegram.initDataUnsafe?.user?.id;
                        setUserId(id || 999);
                        setView('wager');
                        return;
                    }
                } catch (error) {
                    console.error('Auth API Error:', error);
                }
            }
            // Local development fallback
            const fallbackId = (window as any).Telegram?.WebApp?.initDataUnsafe?.user?.id || 12345;
            setUserId(fallbackId);
            setView('wager');
        };
        initTelegramAuth();
    }, []);

    const handleWagerSelected = (selectedWager: number) => {
        setWager(selectedWager);
        setView('lobby');
    };

    const handleEnterGame = (roomId: number) => {
        setActiveRoomId(roomId);
        setView('game');
    };

    const handleBackToWager = () => {
        setWager(null);
        setActiveRoomId(null);
        setView('wager');
    };

    return (
        <div className="min-h-screen bg-slate-950 text-white font-sans">
            {view === 'auth' && (
                <div className="flex flex-col items-center justify-center min-h-screen">
                    <div className="w-12 h-12 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                    <p className="text-indigo-400 font-medium uppercase tracking-widest text-xs">Authenticating...</p>
                </div>
            )}

            {view === 'wager' && userId && (
                <WagerSelection userId={userId} onWagerSelected={handleWagerSelected} />
            )}

            {view === 'lobby' && userId && wager !== null && (
                <Lobby
                    userId={userId}
                    wager={wager}
                    onEnterGame={handleEnterGame}
                    onBack={handleBackToWager}
                />
            )}

            {view === 'game' && activeRoomId && userId && (
                <GameRoom
                    roomId={activeRoomId}
                    userId={userId}
                    onLeave={handleBackToWager} // Redirects to Wager Selection
                />
            )}
        </div>
    );
};

export default App;