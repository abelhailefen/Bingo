import { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { Lobby } from './components/Lobby';
import { GameRoom } from './components/GameRoom';
import { WagerSelection } from './components/WagerSelection';
import { telegramInit } from './services/api';

const App = () => {
    const { t, i18n } = useTranslation();
    const [view, setView] = useState<'auth' | 'wager' | 'lobby' | 'game'>('auth');
    const [userId, setUserId] = useState<number | null>(null);
    const [, setAuthToken] = useState<string | null>(null);
    const [wager, setWager] = useState<number | null>(null);
    const [activeRoomId, setActiveRoomId] = useState<number | null>(null);
   // const [debugLogs, setDebugLogs] = useState<string[]>([]);

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


        const checkForActiveGame = async (uid: number) => {
            try {
                // Check if user has any cards in a non-completed room
                const response = await fetch(`/api/rooms/active-room/${uid}`);
                
                if (response.ok) {
                    const data = await response.json();
                    
                    if (data.data && data.data.roomId) {
                        // User has an active game!
                        setActiveRoomId(data.data.roomId);
                        setWager(data.data.cardPrice);
                        setView('game');
                        return true;
                    } else {
                    }
                } else {
                }
            } catch (err) {
            }
            return false;
        };

        const init = async () => {
            const tg = (window as any).Telegram?.WebApp;

            // 1. FAST PATH: Check Local Storage (Instant)
            const savedId = localStorage.getItem('bingo_user_id');
            const savedToken = localStorage.getItem('bingo_token');
            
           
            let currentUserId = null;
            
            // Use saved ID even if token is missing - we can still rejoin
            if (savedId) {
                currentUserId = parseInt(savedId);
                setUserId(currentUserId);
                if (savedToken) {
                    setAuthToken(savedToken);
                }
            }

            // Try to get userId from Telegram if we don't have it from localStorage
            if (!currentUserId && tg?.initDataUnsafe?.user?.id) {
                currentUserId = tg.initDataUnsafe.user.id;
                setUserId(currentUserId);
            }

            // Check for active game FIRST before showing wager selection
            if (currentUserId) {
                const hasActiveGame = await checkForActiveGame(currentUserId);
                
                if (hasActiveGame) {
                    // View is already set to 'game' by checkForActiveGame
                } else {
                    setView('wager');
                }
            } else {
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

    const toggleLanguage = () => {
        i18n.changeLanguage(i18n.language === 'en' ? 'am' : 'en');
    };

    return (
        <div className="min-h-screen bg-slate-950 text-white font-sans relative">
            {/* Language Toggle Button */}
            <div className="absolute top-4 right-4 z-50">
                <button 
                    onClick={toggleLanguage}
                    className="flex items-center gap-2 bg-slate-800 hover:bg-slate-700 border border-slate-600 px-3 py-1.5 text-xs font-bold rounded-full transition-colors"
                >
                    <span className="text-slate-400">{t('Switch Language')}</span>
                    <span className="text-white uppercase px-1.5 py-0.5 bg-indigo-600 rounded-md">
                        {i18n.language === 'en' ? 'EN' : 'AM'}
                    </span>
                </button>
            </div>

            {view === 'auth' && (
                <div className="flex flex-col items-center justify-center min-h-screen">
                    <div className="w-12 h-12 border-4 border-indigo-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                    <p className="text-indigo-400 font-medium uppercase tracking-widest text-xs">{t('Authenticating...')}</p>
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