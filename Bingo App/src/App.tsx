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
    const [debugLogs, setDebugLogs] = useState<string[]>([]);

    const addLog = (msg: string) => {
        setDebugLogs(prev => [...prev, `${new Date().toLocaleTimeString()}: ${msg}`]);
        console.log(msg);
    };

    useEffect(() => {
        const initTelegramAuth = async () => {
            const telegram = (window as any).Telegram?.WebApp;

            if (telegram) {
                // IMPORTANT: Call ready() immediately so Telegram knows the app is active
                telegram.ready();
                telegram.expand();

                // If initData is missing immediately, wait a tiny bit for injection
                if (!telegram.initData && !telegram.initDataUnsafe?.user) {
                    addLog('[Auth] Data missing, retrying in 100ms...');
                    await new Promise(resolve => setTimeout(resolve, 100));
                }

                addLog('[Debug] Telegram object exists');
                addLog('[Debug] initData length: ' + (telegram.initData?.length || 0));

                if (telegram.initData) {
                    addLog('[Auth] Attempting API authentication...');
                    try {
                        const response = await telegramInit(telegram.initData);
                        if (!response.isFailed && response.data) {
                            addLog('[Auth] Success! User ID: ' + response.data.userId);
                            setAuthToken(response.data.token);
                            localStorage.setItem('bingo_token', response.data.token);
                            setUserId(response.data.userId);
                            setView('wager');
                            return;
                        }
                    } catch (error) {
                        addLog('[Auth] API Error: ' + error);
                    }
                }
            }

            // Fallback Logic
            const fallbackId = telegram?.initDataUnsafe?.user?.id || 12345;
            if (fallbackId !== 12345) {
                addLog('[Auth] Using User ID from Unsafe Data: ' + fallbackId);
                setUserId(fallbackId);
                setView('wager');
            } else {
                addLog('[Auth] FATAL: No Telegram data found.');
                // You might want to show an "Open from Telegram" error here instead of fallback 12345
            }
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

            {/* DEBUG OVERLAY - Remove after debugging */}
            {debugLogs.length > 0 && (
                <div className="fixed bottom-0 left-0 right-0 bg-black/90 text-white p-2 max-h-48 overflow-y-auto text-xs font-mono z-50">
                    <div className="flex justify-between items-center mb-1">
                        <span className="font-bold text-yellow-400">DEBUG LOGS (User ID: {userId})</span>
                        <button onClick={() => setDebugLogs([])} className="text-red-400">Clear</button>
                    </div>
                    {debugLogs.map((log, i) => (
                        <div key={i} className="border-b border-white/10 py-1">{log}</div>
                    ))}
                </div>
            )}
        </div>
    );
};

export default App;