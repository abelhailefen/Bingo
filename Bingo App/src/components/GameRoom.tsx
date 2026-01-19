
export const GameRoom = ({ roomId, userId, onLeave }: any) => {
    const [cards, setCards] = useState<any[]>([]); // Array for up to 2 cards
    const [drawnNumbers, setDrawnNumbers] = useState<number[]>([]);
    const [currentNumber, setCurrentNumber] = useState<string>("");

    useEffect(() => {
        const fetchStatus = async () => {
            const roomRes = await getRoom(roomId);
            if (!roomRes.isFailed) {
                const called = roomRes.data.calledNumbers.map((n: any) => n.number);
                setDrawnNumbers(called);
                // Logic to display B-1, I-20 etc.
                const last = called[called.length - 1];
                if (last) {
                    const prefix = last <= 15 ? 'B' : last <= 30 ? 'I' : last <= 45 ? 'N' : last <= 60 ? 'G' : 'O';
                    setCurrentNumber(`${prefix}-${last}`);
                }
            }

            const cardRes = await getMyCards(roomId, userId);
            if (!cardRes.isFailed) {
                setCards(cardRes.data); // Should contain 1 or 2 cards
            }
        };
        fetchStatus();
        const interval = setInterval(fetchStatus, 3000);
        return () => clearInterval(interval);
    }, []);

    return (
        <div className="flex h-screen bg-indigo-900 text-white overflow-hidden">
            {/* LEFT: 1-75 Progress Board */}
            <div className="w-1/3 bg-indigo-800 p-2 border-r border-indigo-700 overflow-y-auto">
                <div className="grid grid-cols-5 gap-1 text-[10px] font-bold">
                    {['B','I','N','G','O'].map(l => <div key={l} className="text-center py-1 text-yellow-400">{l}</div>)}
                    {Array.from({ length: 75 }, (_, i) => i + 1).map(num => {
                        const isDrawn = drawnNumbers.includes(num);
                        return (
                            <div key={num} className={`text-center py-1 rounded ${isDrawn ? 'bg-green-600' : 'bg-indigo-400/30 text-indigo-200'}`}>
                                {num}
                            </div>
                        );
                    })}
                </div>
            </div>

            {/* RIGHT: Active Cards & Controls */}
            <div className="w-2/3 flex flex-col p-4 gap-4 overflow-y-auto">
                <div className="flex justify-between items-center bg-indigo-950 p-3 rounded-xl">
                    <div>
                        <p className="text-xs">Current Call</p>
                        <h2 className="text-2xl font-black">{currentNumber || "---"}</h2>
                    </div>
                    <div className="text-right">
                        <p className="text-xs">Players: 84</p>
                        <p className="text-xs">Call: {drawnNumbers.length}</p>
                    </div>
                </div>

                {/* Render Multiple Boards */}
                <div className="flex flex-col gap-8">
                    {cards.map((card, idx) => (
                        <div key={card.cardId} className="relative">
                            <span className="absolute -top-4 left-0 text-[10px] text-orange-300">Board No.{card.masterCardId}</span>
                            <BingoBoard 
                                board={formatBackendCard(card.numbers || card.masterCard.numbers)} 
                                onCellClick={(r, c) => handleCellClick(idx, r, c)} 
                                gameActive={true}
                                // Highlight cells that are drawn
                                drawnNumbers={drawnNumbers}
                            />
                        </div>
                    ))}
                </div>

                <button className="bg-red-500 py-4 rounded-xl font-bold text-xl mt-4">BINGO!</button>
            </div>
        </div>
    );
};