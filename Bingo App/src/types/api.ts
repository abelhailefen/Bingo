export interface ApiResponse<T> {
    data: T;
    success: boolean;
    isFailed: boolean;
    responseStatus: number;
    message: string;
    messageCode?: string | null;
}