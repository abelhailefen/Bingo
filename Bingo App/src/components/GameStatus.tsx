import React from 'react';
import { getBingoLetter } from '../utils/gameLogic';

interface Props {
    currentNumber: number | null;
    drawnNumbers: number[];
}

export const GameStatus: React.FC<Props> = ({ currentNumber, drawnNumbers }) => {
    const allNumbers = Array.from({ length: 75 }, (_, i) => i + 1);

    return (
        <div className="flex flex-col gap-6 w-full max-w-sm">
            {/* Current Ball Display */}
            <div className="bg-white/10 backdrop-blur-md p-6 rounded-2xl border border-white/20 text-center shadow-2xl relative overflow-hidden group">
                <div className="absolute top-0 left-0 w-full h-full bg-gradient-to-t from-indigo-900/50 to-transparent pointer-events-none" />
                <h2 className="text-white/80 text-sm uppercase tracking-widest font-bold mb-2">Current Ball</h2>

                {currentNumber ? (
                    <div className="animate-bounce-in flex flex-col items-center justify-center">
                        <span className="text-8xl font-black text-transparent bg-clip-text bg-gradient-to-tr from-yellow-300 to-amber-500 drop-shadow-lg">
                            {getBingoLetter(currentNumber)}
                        </span>
                        <span className="text-9xl font-black text-white drop-shadow-[0_4px_4px_rgba(0,0,0,0.5)]">
                            {currentNumber}
                        </span>
                    </div>
                ) : (
                    <div className="h-40 flex items-center justify-center text-white/30 text-xl font-medium italic">
                        Waiting to draw...
                    </div>
                )}
            </div>

            {/* Board Tracking */}
            <div className="bg-white/90 p-4 rounded-xl shadow-xl">
                <h3 className="text-slate-500 text-xs font-bold uppercase mb-3">Called Numbers</h3>
                <div className="grid grid-cols-10 gap-1">
                    {allNumbers.map(num => (
                        <div
                            key={num}
                            className={`
                aspect-square flex items-center justify-center text-[10px] sm:text-xs font-bold rounded-sm transition-colors
                ${drawnNumbers.includes(num)
                                    ? 'bg-slate-800 text-white'
                                    : 'bg-slate-100 text-slate-300'}
              `}
                        >
                            {num}
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};
