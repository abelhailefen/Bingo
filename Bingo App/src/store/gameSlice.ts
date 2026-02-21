import { createSlice, type PayloadAction } from '@reduxjs/toolkit';
import type { MasterCard } from '../types/gameplay';

interface GameState {
    roomId: number | null;
    wager: number | null;
    myCards: MasterCard[];
    lockedCards: number[];
    serverTimeOffset: number;
}

const initialState: GameState = {
    roomId: null,
    wager: null,
    myCards: [],
    lockedCards: [],
    serverTimeOffset: 0,
};

export const gameSlice = createSlice({
    name: 'game',
    initialState,
    reducers: {
        setServerTimeOffset: (state, action: PayloadAction<number>) => {
            state.serverTimeOffset = action.payload;
        },
        // Example inside gameSlice.ts
        setLobbyData: (state, action) => {
            state.roomId = action.payload.roomId;
            state.wager = action.payload.wager;
            // Clear cards if the room has changed
            if (action.payload.roomId === null) {
                state.myCards = [];
                state.lockedCards = [];
            }
        }, 
        updateMyCards: (state, action: PayloadAction<MasterCard[]>) => {
            state.myCards = action.payload;
        },
        updateLockedCards: (state, action: PayloadAction<number[]>) => {
            state.lockedCards = action.payload;
        },
        // NEW: Handle SignalR updates directly in the state
        syncLockedCards: (state, action: PayloadAction<{ cardId: number; isLocked: boolean }>) => {
            const { cardId, isLocked } = action.payload;
            if (isLocked) {
                if (!state.lockedCards.includes(cardId)) {
                    state.lockedCards.push(cardId);
                }
            } else {
                state.lockedCards = state.lockedCards.filter(id => id !== cardId);
            }
        },
        resetLobby: () => initialState
    },
});

export const { setLobbyData, updateMyCards, updateLockedCards, syncLockedCards, resetLobby } = gameSlice.actions;
export default gameSlice.reducer;