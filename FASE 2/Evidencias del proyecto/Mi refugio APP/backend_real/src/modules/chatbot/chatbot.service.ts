import { Injectable } from '@nestjs/common';
import axios from 'axios';

@Injectable()
export class ChatbotService {
    private readonly ollamaUrl = process.env.OLLAMA_BASE_URL || 'http://localhost:11434';
    private readonly model = process.env.OLLAMA_MODEL || 'llama3.2';

    // In-memory history for demo purposes (replace with DB if needed)
    private history: any[] = [];

    async sendMessage(message: string) {
        // Add user message to history
        const userMsg = {
            id: Date.now().toString(),
            role: 'user',
            content: message,
            createdAt: new Date().toISOString(),
        };
        this.history.push(userMsg);

        try {
            // Call Ollama
            const response = await axios.post(`${this.ollamaUrl}/api/generate`, {
                model: this.model,
                prompt: message,
                stream: false,
                options: {
                    num_ctx: 2048, // Limit context window to save memory
                    num_predict: 100, // Limit response length to ~100 tokens
                },
            });

            const botContent = (response.data as any).response;

            // Add bot response to history
            const botMsg = {
                id: (Date.now() + 1).toString(),
                role: 'assistant',
                content: botContent,
                createdAt: new Date().toISOString(),
            };
            this.history.push(botMsg);

            return botMsg;
        } catch (error) {
            console.error('Ollama Error:', error);
            // Fallback response if Ollama is down
            const fallbackMsg = {
                id: (Date.now() + 1).toString(),
                role: 'assistant',
                content: 'Lo siento, no puedo conectar con mi cerebro en este momento. Por favor intenta más tarde.',
                createdAt: new Date().toISOString(),
            };
            this.history.push(fallbackMsg);
            return fallbackMsg;
        }
    }

    async getHistory() {
        return this.history;
    }
}
