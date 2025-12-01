import { SendMessageDto } from '../dto/send-message.dto';
import { ChatResponseDto } from '../dto/chat-response.dto';
import { LlmLocalService, LlmHealth } from './llm-local.service';
export declare class RefuService {
    private readonly llmLocal;
    private readonly logger;
    private readonly assistantPersona;
    constructor(llmLocal: LlmLocalService);
    sendMessage(dto: SendMessageDto): Promise<ChatResponseDto>;
    health(): Promise<LlmHealth>;
    private buildPrompt;
    private normalizeResponse;
    private fallbackAnswer;
    private genericAck;
    private createMetrics;
}
