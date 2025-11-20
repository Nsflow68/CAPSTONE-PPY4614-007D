import { ChatbotService } from './chatbot.service';
import { SendMessageDto } from './dto/send-message.dto';
import { OllamaHealth } from './ollama.service';
export declare class ChatbotController {
    private readonly chatbotService;
    constructor(chatbotService: ChatbotService);
    health(): Promise<OllamaHealth>;
    sendMessage(dto: SendMessageDto): Promise<import("./dto/chat-response.dto").ChatResponseDto>;
}
