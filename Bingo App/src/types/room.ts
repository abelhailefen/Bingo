import { RoomStatus } from './enums';

export interface RoomPlayer {
    userId: number;
    username: string;
    isReady: boolean;
}

export interface RoomSummary {
    roomId: number;
    name: string;
    roomCode: string;
    status: RoomStatus;
    playerCount: number;
    maxPlayers: number;
    cardPrice: number;
    hostName?: string;
}

export interface Room {
    roomId: number;
    roomCode: string;
    name: string;
    scheduledStartTime: Date;
    status: RoomStatus;
    calledNumbers: { number: number }[];
    players: RoomPlayer[];
}

export interface JoinLobbyResponse {
    roomId: number;
    scheduledStartTime: string;
    takenCardIds: number[]; // Matching the backend DTO fully
}
