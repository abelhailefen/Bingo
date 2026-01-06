const API_URL = 'http://localhost:5249/api/Rooms'; // Replace with your IP

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
}

export const createRoom = async (name: string, hostId: number): Promise<Room> => {
    const response = await fetch(API_URL, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            roomName: name,      // Matches RoomName in C#
            hostUserId: hostId   // Matches HostUserId in C#
        })
    });

    if (!response.ok) {
        const errorDetail = await response.json();
        console.error("Server Error:", errorDetail);
        throw new Error("Failed to create room");
    }

    return response.json();
};

export const joinRoom = async (roomId: number, userId: number): Promise<{ cardId: number }> => {
    const response = await fetch(`${API_URL}/${roomId}/join?userId=${userId}`, {
        method: 'POST'
    });
    return response.json();
};

export const getRoom = async (roomId: number): Promise<Room> => {
    const response = await fetch(`${API_URL}/${roomId}`);
    return response.json();
};

export const drawNumber = async (roomId: number): Promise<number> => {
    const response = await fetch(`${API_URL}/${roomId}/draw`, { method: 'POST' });
    return response.json();
};