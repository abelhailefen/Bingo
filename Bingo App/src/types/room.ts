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
    status: RoomStatus;
    calledNumbers: { number: number }[];
    players: RoomPlayer[];
}