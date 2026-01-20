import React from 'react';
import type { BingoBoard as BingoBoardType } from '../utils/gameLogic';
import { BingoCell } from './BingoCell';

interface Props {
    board: BingoBoardType;
    onCellClick: (rowIndex: number, colIndex: number) => void;
    gameActive: boolean;
}

export const BingoBoard: React.FC<Props> = ({ board, onCellClick, gameActive }) => {
    return (
        <div className="bg-white/10 backdrop-blur-md p-6 rounded-2xl shadow-2xl border border-white/20">
            {/* Header Row */}
            <div className="grid grid-cols-5 gap-3 mb-4">
                {['B', 'I', 'N', 'G', 'O'].map((letter, i) => (
                    <div key={letter} className="aspect-square flex items-center justify-center">
                        <span className={`
                            text-4xl sm:text-5xl font-black drop-shadow-md
                            ${i === 0 ? 'text-rose-500' : ''}
                            ${i === 1 ? 'text-amber-500' : ''}
                            ${i === 2 ? 'text-emerald-500' : ''}
                            ${i === 3 ? 'text-sky-500' : ''}
                            ${i === 4 ? 'text-violet-500' : ''}
                        `}>
                            {letter}
                        </span>
                    </div>
                ))}
            </div>

            {/* Grid */}
            <div className="grid grid-cols-5 gap-3">
                {board.map((row, rowIndex) =>
                    row.map((cell, colIndex) => 
                        cell ? (
                            <BingoCell
                                key={cell.id}
                                cell={cell}
                                onClick={() => onCellClick(rowIndex, colIndex)}
                                disabled={!gameActive}
                            />
                        ) : null
                    )
                )}
            </div>
        </div>
    );
};
