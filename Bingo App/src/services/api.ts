import axios from 'axios';
import type { ApiResponse } from '../types/api';
import type { Room, RoomSummary } from '../types/room';
import type { MasterCard } from '../types/gameplay';

const api = axios.create({
    baseURL: '/api', // Use relative path if proxied, or full URL
    headers: { 'Content-Type': 'application/json' }
});

api.interceptors.request.use((config) => {
    const token = localStorage.getItem('bingo_token');
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
});

// Auth
export const telegramInit = async (initData: string): Promise<ApiResponse<string>> => {
    const response = await api.post('/auth/telegram-init', { initData });
    return response.data;
};
export const devLogin = async (userId: number, username: string): Promise<ApiResponse<string>> => {
    const response = await api.post('/auth/dev-login', { userId, username });
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

// Updated to include roomId
export const getMasterCard = async (roomId: number, cardId: number): Promise<ApiResponse<MasterCard>> => {
    const response = await api.get(`/rooms/${roomId}/master-card/${cardId}`);
    return response.data;
};

// Automatic grouping: finds or creates a waiting room
export const joinAutoLobby = async (userId: number): Promise<ApiResponse<{ roomId: number }>> => {
    const response = await api.post('/rooms/lobby/join', { userId });
    return response.data;
};

// SignalR: Notify others that I am previewing/locking a card
export const selectCardLock = async (roomId: number, masterCardId: number, isLocked: boolean): Promise<ApiResponse<void>> => {
    const response = await api.post(`/rooms/${roomId}/select-card`, { masterCardId, isLocked });
    return response.data;
};

export const drawNumber = async (roomId: number, userId: number): Promise<ApiResponse<number>> => {
    const response = await api.post(`/rooms/${roomId}/draw`, { userId });
    return response.data;
};
// ... existing imports ...

// Get all cards belonging to the current user in a specific room
export const getMyCards = async (roomId: number, userId: number): Promise<ApiResponse<any[]>> => {
    const response = await api.get(`/rooms/${roomId}/users/${userId}/cards`);
    return response.data;
};

// Notify the server that the user is claiming a win
export const claimBingo = async (roomId: number, userId: number): Promise<ApiResponse<any>> => {
    const response = await api.post(`/rooms/${roomId}/claim`, { userId });
    return response.data;
};
export default api;