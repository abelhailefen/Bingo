import axios from 'axios';
import type { ApiResponse } from '../types/api';
import type { Room, RoomSummary, JoinLobbyResponse } from '../types/room';
import type { MasterCard } from '../types/gameplay';
import type { User } from '../types/user';

const api = axios.create({
    baseURL: '/api', // Use relative path if proxied, or full URL
    headers: { 'Content-Type': 'application/json' }
});

api.interceptors.request.use((config) => {
    const token = localStorage.getItem('bingo_token');
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
});

// Import the store dynamically to avoid circular dependencies during initialization
let store: any;
export const injectStore = (_store: any) => {
    store = _store;
};

api.interceptors.response.use((response) => {
    if (store && response.headers['date']) {
        const serverTime = new Date(response.headers['date']).getTime();
        const localTime = Date.now();
        // Offset = ServerTime - LocalTime
        // To get the true time: Date.now() + offset
        const offset = serverTime - localTime;
        
        // Only dispatch if the drift is significant (> 500ms differnce) to avoid spamming Redux
        const currentOffset = store.getState().game.serverTimeOffset;
        if (Math.abs(currentOffset - offset) > 500) {
            import('../store/gameSlice').then(module => {
                store.dispatch(module.setLobbyData({ ...store.getState().game, serverTimeOffset: offset }));
                // We actually need the 'setServerTimeOffset' action.
                store.dispatch(module.gameSlice.actions.setServerTimeOffset(offset));
            });
        }
    }
    return response;
});

// Auth
export interface TelegramInitResponse {
    token: string;
    userId: number;
    username: string;
    phoneNumber: string;
}

export const telegramInit = async (initData: string): Promise<ApiResponse<TelegramInitResponse>> => {
    const response = await api.post('/auth/telegram-init', { initData });
    return response.data;
};
export const devLogin = async (userId: number, username: string): Promise<ApiResponse<string>> => {
    const response = await api.post('/auth/dev-login', { userId, username });
    return response.data;
};

// User
export const getUser = async (userId: number): Promise<ApiResponse<User>> => {
    const response = await api.get(`/auth/user`, { params: { userId } });
    return response.data;
};

// Rooms
export const getRooms = async (): Promise<ApiResponse<RoomSummary[]>> => {
    const response = await api.get('/rooms/list');
    return response.data;
};

export const getRoom = async (roomId: number): Promise<ApiResponse<Room>> => {
    const response = await api.get(`/rooms/${roomId}`);
    return response.data;
};

export const createRoom = async (name: string, hostUserId: number): Promise<ApiResponse<{ roomId: number, roomCode: string }>> => {
    const response = await api.post('/rooms/create', { name, hostUserId });
    return response.data;
};

// Gameplay

export const getMasterCard = async (roomId: number, cardId: number): Promise<ApiResponse<MasterCard>> => {
    const response = await api.get(`/rooms/${roomId}/master-card/${cardId}`);
    return response.data;
};

export const joinAutoLobby = async (userId: number, cardPrice: number): Promise<ApiResponse<JoinLobbyResponse>> => {
    const response = await api.post('/rooms/lobby/join', { userId, cardPrice });
    return response.data;
};

export const selectCardLock = async (
    roomId: number,
    masterCardId: number,
    isLocked: boolean,
    userId: number
): Promise<ApiResponse<boolean>> => {
    const response = await api.post(`/rooms/${roomId}/select-card`, {
        masterCardId,
        isLocked,
        userId
    });
    return response.data;
};

export const purchaseCards = async (userId: number, roomId: number, masterCardIds: number[]): Promise<ApiResponse<boolean>> => {
    const response = await api.post('/rooms/purchase', {
        userId,
        roomId,
        masterCardIds
    });
    return response.data;
};

export const drawNumber = async (roomId: number, userId: number): Promise<ApiResponse<number>> => {
    const response = await api.post(`/rooms/${roomId}/draw`, { userId });
    return response.data;
};

export const getMyCards = async (roomId: number, userId: number): Promise<ApiResponse<any[]>> => {
    const response = await api.get(`/rooms/${roomId}/users/${userId}/cards`);
    return response.data;
};

export const claimBingo = async (roomId: number, userId: number): Promise<ApiResponse<any>> => {
    const response = await api.post(`/rooms/${roomId}/claim`, { userId });
    return response.data;
};

export const getTakenCards = async (roomId: number): Promise<ApiResponse<number[]>> => {
    const response = await api.get(`/rooms/${roomId}/taken-cards`);
    return response.data;
};

export const leaveLobby = async (roomId: number, userId: number): Promise<ApiResponse<void>> => {
    const response = await api.post(`/rooms/${roomId}/leave`, { userId });
    return response.data;
};

export default api;