import React from 'react';

interface Props {
    onDraw: () => void;
    onReset: () => void;
    gameActive: boolean;
    drawnCount: number;
}

export const ControlPanel: React.FC<Props> = ({ onDraw, onReset, gameActive, drawnCount }) => {
    return (
        <div className="flex flex-col gap-4 w-full">
            <button
                onClick={onDraw}
                disabled={!gameActive || drawnCount >= 75}
                className="game-btn bg-indigo-600 hover:bg-indigo-700 text-white disabled:opacity-50 disabled:grayscale"
            >
                DRAW NUMBER
            </button>

            <button
                onClick={onReset}
                className="game-btn bg-slate-200 hover:bg-slate-300 text-slate-700"
            >
                NEW GAME
            </button>
        </div>
    );
};
