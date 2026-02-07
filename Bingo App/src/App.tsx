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
            const tg = (window as any).Telegram?.WebApp;

            // 1. FAST PATH: Check Local Storage (Instant)
            const savedId = localStorage.getItem('bingo_user_id');
            const savedToken = localStorage.getItem('bingo_token');
            if (savedId && savedToken) {
                setUserId(parseInt(savedId));
                setAuthToken(savedToken);
                setView('wager');
                // We don't return here; we continue to check if we can refresh the token
            }

            // 2. BACKUP PATH: Check URL for the ?u= ID we added in C#
            const urlParams = new URLSearchParams(window.location.search);
            const urlUserId = urlParams.get('u');

            if (tg) {
                tg.ready();
                tg.expand();

                // 3. SECURE PATH: Try to get a fresh token from Telegram InitData
                if (tg.initData && tg.initData.length > 0) {
                    try {
                        const response = await telegramInit(tg.initData);
                        if (!response.isFailed && response.data) {
                            const freshId = response.data.userId;
                            const freshToken = response.data.token;

                            // Save for next time
                            localStorage.setItem('bingo_user_id', freshId.toString());
                            localStorage.setItem('bingo_token', freshToken);

                            setUserId(freshId);
                            setAuthToken(freshToken);
                            setView('wager');
                            return;
                        }
                    } catch (error) {
                        console.error("Secure auth failed, using fallbacks");
                    }
                }

                // 4. TELEGRAM UNSAFE PATH: If secure auth failed, use the ID Telegram provides anyway
                const telegramUserId = tg.initDataUnsafe?.user?.id;
                if (telegramUserId) {
                    setUserId(telegramUserId);
                    if (view === 'auth') setView('wager');
                    return;
                }
            }

            // 5. URL FALLBACK: If we have the ID from the URL, use it
            if (urlUserId) {
                setUserId(parseInt(urlUserId));
                if (view === 'auth') setView('wager');
                return;
            }

            // FINAL FALLBACK: For local browser testing only
            if (!userId) {
                setUserId(12345);
                setView('wager');
            }
        };

        initTelegramAuth();
    }, [view, userId]);

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
                    onLeave={handleBackToWager}
                />
            )}
        </div>
    );
};

export default App;