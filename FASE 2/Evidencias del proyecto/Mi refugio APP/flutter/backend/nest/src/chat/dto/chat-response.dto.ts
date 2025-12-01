export class ChatResponseDto {
  reply: string;
  provider: string;
  metrics: {
    latencyMs: number;
    provider: string;
    model?: string;
    timestamp: string;
  };
}
