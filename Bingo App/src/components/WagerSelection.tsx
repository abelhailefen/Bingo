import { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { getUser } from '../services/api';

interface WagerSelectionProps {
    userId: number;
    onWagerSelected: (wager: number) => void;
}

/**
 * WagerSelection Component
 * Allows users to choose their wager amount (5, 10, 20, or 50 birr)
 */
export const WagerSelection = ({ userId, onWagerSelected }: WagerSelectionProps) => {
    const { t, i18n } = useTranslation();
    const [selectedWager, setSelectedWager] = useState<number | null>(null);
    const [balance, setBalance] = useState<number | null>(null);
    const wagerOptions = [5, 10, 20, 50];

    useEffect(() => {
        if (userId) {
            getUser(userId).then(res => {
                if (!res.isFailed && res.data) {
                    setBalance(res.data.balance);
                }
            });
        }
    }, [userId]);

    const handleWagerClick = (amount: number) => {
        if (balance !== null && balance < amount) return;
        setSelectedWager(amount);
    };

    const handleContinue = () => {
        if (selectedWager) {
            onWagerSelected(selectedWager);
        }
    };

    return (
        <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center p-4 relative">
            {/* Language Toggle */}
            <div className="absolute top-4 right-4">
                <button 
                    onClick={() => i18n.changeLanguage(i18n.language === 'en' ? 'am' : 'en')}
                    className="flex items-center gap-1 bg-slate-800/80 hover:bg-slate-700 backdrop-blur-md border border-slate-600 px-3 py-1.5 text-xs font-bold rounded-full transition-colors"
                >
                    <span className="text-slate-400">🌍</span>
                    <span className="text-white uppercase">
                        {i18n.language === 'en' ? 'EN' : 'AM'}
                    </span>
                </button>
            </div>

            <div className="max-w-md w-full">
                {/* Header */}
                <div className="text-center mb-8">
                    <h1 className="text-4xl font-bold text-white mb-2">
                        {t('Choose Your Wager')}
                    </h1>
                    <p className="text-gray-300">
                        {t('Select how much birr you want to wager for this game')}
                    </p>
                    {balance !== null && (
                        <div className="mt-4 inline-block bg-slate-800/50 px-4 py-2 rounded-full border border-green-500/30">
                            <span className="text-gray-400 text-sm">{t('Your Balance:')} </span>
                            <span className="text-green-400 font-bold">{balance} {t('ETB')}</span>
                        </div>
                    )}
                </div>

                {/* Wager Options Grid */}
                <div className="grid grid-cols-2 gap-4 mb-8">
                    {wagerOptions.map((amount) => {
                        const canAfford = balance === null || balance >= amount;
                        return (
                            <button
                                key={amount}
                                disabled={!canAfford}
                                onClick={() => handleWagerClick(amount)}
                                className={`
                                    relative p-8 rounded-2xl border-2 transition-all duration-300
                                    ${!canAfford 
                                        ? 'border-gray-700 bg-gray-800/50 opacity-50 cursor-not-allowed grayscale'
                                        : selectedWager === amount
                                            ? 'border-purple-500 bg-purple-500/20 scale-105 shadow-lg shadow-purple-500/50'
                                            : 'border-gray-600 bg-slate-800/50 hover:border-purple-400 hover:bg-slate-700/50'
                                    }
                                `}
                            >
                                {/* Amount */}
                                <div className="text-center">
                                    <div className={`text-4xl font-bold mb-1 ${!canAfford ? 'text-gray-500' : 'text-white'}`}>
                                        {amount}
                                    </div>
                                    <div className="text-sm text-gray-400 uppercase tracking-wide">
                                        {t('Birr')}
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
                        );
                    })}
                </div>

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
                    {selectedWager ? t('Continue with {{amount}} Birr', { amount: selectedWager }) : t('Select a Wager')}
                </button>

                {/* Back to lobby option (optional) */}
                <div className="text-center mt-4 pb-12">
                    <button className="text-gray-400 hover:text-white transition-colors text-sm">
                        {t('Need more funds? Contact support')}
                    </button>
                </div>
            </div>
        </div>
    );
};
