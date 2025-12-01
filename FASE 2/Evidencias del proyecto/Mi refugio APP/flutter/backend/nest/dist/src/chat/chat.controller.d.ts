import { RefuService } from './refu/refu.service';
import { SendMessageDto } from './dto/send-message.dto';
import { LlmHealth } from './refu/llm-local.service';
export declare class ChatController {
    private readonly refuService;
    constructor(refuService: RefuService);
    health(): Promise<LlmHealth>;
    sendMessageToRefu(dto: SendMessageDto): Promise<import("./dto/chat-response.dto").ChatResponseDto>;
    sendMessage(dto: SendMessageDto): Promise<import("./dto/chat-response.dto").ChatResponseDto>;
}
