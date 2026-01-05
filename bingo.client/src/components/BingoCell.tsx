import React from 'react';
import type { BingoCell as BingoCellType } from '../utils/gameLogic';

interface Props {
    cell: BingoCellType;
    onClick: () => void;
    disabled: boolean;
}

export const BingoCell: React.FC<Props> = ({ cell, onClick, disabled }) => {
    const isFree = cell.value === 'FREE';

    return (
        <button
            onClick={onClick}
            disabled={disabled || isFree}
            className={`
        aspect-square flex items-center justify-center text-xl sm:text-3xl font-bold rounded-xl transition-all duration-200 relative overflow-hidden group
        ${cell.marked
                    ? 'bg-gradient-to-br from-yellow-400 to-orange-600 text-white shadow-inner scale-95 ring-4 ring-orange-200/50'
                    : 'bg-white text-slate-700 shadow-[0_4px_0_0_#cbd5e1] hover:shadow-[0_2px_0_0_#cbd5e1] hover:translate-y-[2px] active:shadow-none active:translate-y-[4px]'}
        ${isFree ? 'bg-gradient-to-br from-pink-500 to-rose-600 text-white shadow-inner ring-4 ring-pink-200/50' : ''}
        disabled:cursor-not-allowed disabled:opacity-90
      `}
            aria-label={`${isFree ? 'Free Space' : cell.value} ${cell.marked ? 'marked' : 'unmarked'}`}
        >
            {/* Shine effect */}
            {!cell.marked && !isFree && (
                <div className="absolute inset-0 bg-gradient-to-tr from-white/0 via-white/40 to-white/0 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
            )}

            <span className="relative z-10 drop-shadow-sm">
                {isFree ? '★' : cell.value}
            </span>
        </button>
    );
};
