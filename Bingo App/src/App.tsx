import { useState, useEffect } from 'react';
import { Lobby } from './components/Lobby';
import { GameRoom } from './components/GameRoom';

// Access Telegram WebApp
const tg = (window as any).Telegram?.WebApp;

function App() {
    const [roomId, setRoomId] = useState<number | null>(null);

    const [userId, setUserId] = useState<number>(tg?.initDataUnsafe?.user?.id || 12345);
    const [userName, setUserName] = useState<string>(tg?.initDataUnsafe?.user?.first_name || "Guest");
    
    // Initialize Auth (Telegram or Dev)
    useEffect(() => {
        const initAuth = async () => {
            if (tg?.initData) {
                tg.expand();
                tg.ready();
                // Real Telegram Auth would go here (calling telegramInit)
            } else {
                // Dev Auth for Browser
                try {
                    const { devLogin } = await import('./services/api');
                    await devLogin(userId, userName);
                    console.log("Dev Login Successful for user:", userId);
                } catch (e) {
                    console.error("Dev Login Failed", e);
                }
            }
        };

        initAuth();
    }, []);

    return (
        <div className="min-h-screen bg-slate-900 text-white flex flex-col items-center p-4">
            <header className="py-4">
                <h1 className="text-4xl font-black bg-gradient-to-r from-yellow-400 to-orange-500 bg-clip-text text-transparent">
                    BINGO BOT
                </h1>
            </header>

            {!roomId ? (
                <Lobby
                    userId={userId}
                    userName={userName}
                    onRoomEntered={(id) => setRoomId(id)}
                />
            ) : (
                <GameRoom
                    roomId={roomId}
                    userId={userId}
                    onLeave={() => setRoomId(null)}
                />
            )}
        </div>
    );
}

export default App;