export interface ApiResponse<T> {
    data: T;
    isFailed: boolean;
    responseStatus: number;
    message: string;
    messageCode?: string | null;
}