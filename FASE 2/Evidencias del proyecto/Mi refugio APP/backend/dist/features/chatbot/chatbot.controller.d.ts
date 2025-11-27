import { ChatbotService } from './chatbot.service';
export declare class ChatbotController {
    private readonly chatbotService;
    constructor(chatbotService: ChatbotService);
    history(): {
        data: import("./chatbot.service").ChatMessage[];
    };
    send(message: string): {
        data: import("./chatbot.service").ChatMessage;
    };
}
