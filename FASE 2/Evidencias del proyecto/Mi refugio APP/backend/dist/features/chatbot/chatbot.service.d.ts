export interface ChatMessage {
    id: string;
    role: 'user' | 'assistant';
    content: string;
    createdAt: string;
}
export declare class ChatbotService {
    private readonly history;
    getHistory(): ChatMessage[];
    sendMessage(message: string): ChatMessage;
    private generateResponse;
}
