export interface ChatMetrics {
    latencyMs: number;
    provider: string;
    model?: string;
    timestamp: string;
}
export interface ChatResponseDto {
    reply: string;
    provider: string;
    metrics: ChatMetrics;
}
