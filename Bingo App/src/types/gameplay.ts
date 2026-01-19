export interface MasterCardNumber {
    positionRow: number;
    positionCol: number;
    number: number | null; // null is the '*' free space
}

export interface MasterCard {
    masterCardId: number;
    numbers: MasterCardNumber[];
}

export interface CardNumberDto {
    number: number | null;
    positionRow: number;
    positionCol: number;
    isMarked: boolean;
}

export interface Card {
    cardId: number;
    userId: number;
    masterCardId: number;
    numbers: CardNumberDto[];
}