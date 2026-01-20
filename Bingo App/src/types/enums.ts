export const RoomStatus = {
    Waiting: 0,
    InProgress: 1,
    Completed: 2
} as const;

export type RoomStatus = typeof RoomStatus[keyof typeof RoomStatus];

export const WinPattern = {
    Line: 0,
    FullHouse: 1,
    Blackout: 2
} as const;

export type WinPattern = typeof WinPattern[keyof typeof WinPattern];
