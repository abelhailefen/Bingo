import { useState } from 'react';

interface WagerSelectionProps {
    onWagerSelected: (wager: number) => void;
}

/**
 * WagerSelection Component
 * Allows users to choose their wager amount (5, 10, 20, or 50 birr)
 */
export const WagerSelection = ({ onWagerSelected }: WagerSelectionProps) => {
    const [selectedWager, setSelectedWager] = useState<number | null>(null);
    const wagerOptions = [5, 10, 20, 50];

    const handleWagerClick = (amount: number) => {
        setSelectedWager(amount);
    };

    const handleContinue = () => {
        if (selectedWager) {
            onWagerSelected(selectedWager);
        }
    };

    return (
        <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center p-4">
            <div className="max-w-md w-full">
                {/* Header */}
                <div className="text-center mb-8">
                    <h1 className="text-4xl font-bold text-white mb-2">
                        Choose Your Wager
                    </h1>
                    <p className="text-gray-300">
                        Select how much birr you want to wager for this game
                    </p>
                </div>

                {/* Wager Options Grid */}
                <div className="grid grid-cols-2 gap-4 mb-8">
                    {wagerOptions.map((amount) => (
                        <button
                            key={amount}
                            onClick={() => handleWagerClick(amount)}
                            className={`
                                relative p-8 rounded-2xl border-2 transition-all duration-300
                                ${selectedWager === amount
                                    ? 'border-purple-500 bg-purple-500/20 scale-105 shadow-lg shadow-purple-500/50'
                                    : 'border-gray-600 bg-slate-800/50 hover:border-purple-400 hover:bg-slate-700/50'
                                }
                            `}
                        >
                            {/* Amount */}
                            <div className="text-center">
                                <div className="text-4xl font-bold text-white mb-1">
                                    {amount}
                                </div>
                                <div className="text-sm text-gray-400 uppercase tracking-wide">
                                    Birr
                                </div>
                            </div>

                            {/* Selected Indicator */}
                            {selectedWager === amount && (
                                <div className="absolute top-3 right-3">
                                    <svg
                                        className="w-6 h-6 text-purple-400"
                                        fill="currentColor"
                                        viewBox="0 0 20 20"
                                    >
                                        <path
                                            fillRule="evenodd"
                                            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                                            clipRule="evenodd"
                                        />
                                    </svg>
                                </div>
                            )}
                        </button>
                    ))}
                </div>

                {/* Continue Button */}
                <button
                    onClick={handleContinue}
                    disabled={!selectedWager}
                    className={`
                        w-full py-4 rounded-xl font-semibold text-lg transition-all duration-300
                        ${selectedWager
                            ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white hover:from-purple-500 hover:to-pink-500 shadow-lg shadow-purple-500/50'
                            : 'bg-gray-700 text-gray-500 cursor-not-allowed'
                        }
                    `}
                >
                    {selectedWager ? `Continue with ${selectedWager} Birr` : 'Select a Wager'}
                </button>

                {/* Back to lobby option (optional) */}
                <div className="text-center mt-4">
                    <button className="text-gray-400 hover:text-white transition-colors text-sm">
                        Need more funds? Contact support
                    </button>
                </div>
            </div>
        </div>
    );
};
