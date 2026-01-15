import axios from 'axios';

const api = axios.create({
    baseURL: '/api',
    headers: {
        'Content-Type': 'application/json'
    }
});

// Add a request interceptor to add the auth token to requests
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('bingo_token');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

export interface ApiResponse<T> {
    data: T;
    isSuccess: boolean;
    message: string;
    errors: string[];
}

export interface CardNumber {
    number: number;
    positionRow: number;
    positionCol: number;
    isMarked: boolean;
}

export interface Card {
    cardId: number;
    userId: number;
    numbers: CardNumber[];
}

export interface Room {
    roomId: number;
    roomCode: string;
    name: string;
    status: number;
    calledNumbers: { number: number }[];
    cards: Card[];
    players: any[]; // RoomPlayer[]
}

export interface RoomSummary {
    roomId: number;
    name: string;
    roomCode: string;
    hostName: string;
    playerCount: number;
    status: string;
}

// Auth
export const telegramInit = async (initData: string): Promise<ApiResponse<{ token: string; user: any }>> => {
    const response = await api.post('/auth/telegram-init', { initData });
    return response.data;
};

// Rooms
export const createRoom = async (name: string, hostUserId: number): Promise<ApiResponse<{ roomId: number, roomCode: string }>> => {
    const response = await api.post('/rooms/create', { name, hostUserId });
    return response.data;
};

export const joinRoom = async (roomId: number, userId: number): Promise<ApiResponse<string>> => {
    const response = await api.post(`/rooms/${roomId}/join`, { userId });
    return response.data;
};

export const getRooms = async (): Promise<ApiResponse<RoomSummary[]>> => {
    const response = await api.get('/rooms/list');
    return response.data;
};

export const getRoom = async (roomId: number): Promise<ApiResponse<Room>> => {
    const response = await api.get(`/rooms/${roomId}`);
    return response.data;
};

// Gameplay
export const drawNumber = async (roomId: number, userId: number): Promise<ApiResponse<number>> => {
    const response = await api.post(`/rooms/${roomId}/draw`, { userId });
    return response.data;
};

export const claimWin = async (roomId: number, userId: number, cardId: number, winType: number): Promise<ApiResponse<string>> => {
    const response = await api.post(`/rooms/${roomId}/claim`, { userId, cardId, winType });
    return response.data;
};

export default api;