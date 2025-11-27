import { SendMessageDto } from './dto/send-message.dto';
import { ChatResponseDto } from './dto/chat-response.dto';
import { OllamaService, OllamaHealth } from './ollama.service';
export declare class ChatbotService {
    private readonly ollama;
    private readonly logger;
    private readonly assistantPersona;
    constructor(ollama: OllamaService);
    sendMessage(dto: SendMessageDto): Promise<ChatResponseDto>;
    health(): Promise<OllamaHealth>;
    private buildPrompt;
    private normalizeResponse;
    private fallbackAnswer;
    private genericAck;
    private createMetrics;
}
