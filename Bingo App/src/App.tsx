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

        const addLog = (msg: string) => {
            console.log(msg);
            setDebugLogs(prev => [...prev, msg]);
        };

        const checkForActiveGame = async (uid: number) => {
            try {
                addLog(`Checking for active game for user: ${uid}`);
                // Check if user has any cards in a non-completed room
                const response = await fetch(`/api/rooms/active-room/${uid}`);
                addLog(`API response status: ${response.status}`);
                
                if (response.ok) {
                    const data = await response.json();
                    addLog(`API data: ${JSON.stringify(data)}`);
                    
                    if (data.data && data.data.roomId) {
                        // User has an active game!
                        addLog(`✅ Found active game! Room: ${data.data.roomId}`);
                        setActiveRoomId(data.data.roomId);
                        setWager(data.data.cardPrice);
                        setView('game');
                        return true;
                    } else {
                        addLog('No active room in response data');
                    }
                } else {
                    addLog('API response not OK');
                }
            } catch (err) {
                addLog(`Error: ${err}`);
            }
            return false;
        };

        const init = async () => {
            addLog('🚀 Starting app initialization');
            const tg = (window as any).Telegram?.WebApp;

            // 1. FAST PATH: Check Local Storage (Instant)
            const savedId = localStorage.getItem('bingo_user_id');
            const savedToken = localStorage.getItem('bingo_token');
            
            addLog(`Saved id: ${savedId}`);
            addLog(`Saved token: ${savedToken ? 'exists' : 'missing'}`);
            
            let currentUserId = null;
            
            // Use saved ID even if token is missing - we can still rejoin
            if (savedId) {
                currentUserId = parseInt(savedId);
                setUserId(currentUserId);
                if (savedToken) {
                    setAuthToken(savedToken);
                }
                addLog(`Using saved userId: ${currentUserId}`);
            }

            // Try to get userId from Telegram if we don't have it from localStorage
            if (!currentUserId && tg?.initDataUnsafe?.user?.id) {
                currentUserId = tg.initDataUnsafe.user.id;
                setUserId(currentUserId);
                addLog(`Using Telegram userId: ${currentUserId}`);
            }

            // Check for active game FIRST before showing wager selection
            if (currentUserId) {
                addLog('Checking for active games...');
                const hasActiveGame = await checkForActiveGame(currentUserId);
                addLog(`Has active game: ${hasActiveGame}`);
                
                if (hasActiveGame) {
                    addLog('✅ Active game found, staying in game view');
                    // View is already set to 'game' by checkForActiveGame
                } else {
                    addLog('No active game, showing wager selection');
                    setView('wager');
                }
            } else {
                addLog('No userId available, running full auth flow');
                // No user ID yet, continue with full auth flow
                await initTelegramAuth();
            }
        };

        init();
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
                    onLeave={handleBackToWager}
                />
            )}
            
            {/* Debug logs overlay */}
            {debugLogs.length > 0 && (
                <div style={{
                    position: 'fixed',
                    top: 0,
                    left: 0,
                    right: 0,
                    background: 'rgba(0,0,0,0.9)',
                    color: '#0f0',
                    padding: '10px',
                    fontSize: '10px',
                    fontFamily: 'monospace',
                    maxHeight: '200px',
                    overflow: 'auto',
                    zIndex: 9999,
                    borderBottom: '2px solid #0f0'
                }}>
                    <button 
                        onClick={() => setDebugLogs([])}
                        style={{
                            position: 'absolute',
                            top: '5px',
                            right: '5px',
                            background: '#f00',
                            color: '#fff',
                            border: 'none',
                            padding: '2px 8px',
                            cursor: 'pointer',
                            fontSize: '10px'
                        }}
                    >
                        Clear
                    </button>
                    <div style={{ fontWeight: 'bold', marginBottom: '5px' }}>🐛 DEBUG LOGS:</div>
                    {debugLogs.map((log, i) => (
                        <div key={i} style={{ marginBottom: '2px' }}>{log}</div>
                    ))}
                </div>
            )}
        </div>
    );
};

export default App;