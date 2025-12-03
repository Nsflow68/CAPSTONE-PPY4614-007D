import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class ChatbotService {
  private readonly logger = new Logger(ChatbotService.name);
  private readonly ollamaUrl = process.env.LLM_BASE_URL || 'http://127.0.0.1:11434';

  constructor(private readonly httpService: HttpService) {}

  async sendMessage(payload: any) {
    const { prompt, model, history } = payload;
    
    // Construct the prompt for Ollama
    const messages = history ? history.map((msg: any) => ({
      role: msg.isUser ? 'user' : 'assistant',
      content: msg.text,
    })) : [];

    messages.push({ role: 'user', content: prompt });

    try {
      const response = await firstValueFrom(
        this.httpService.post(`${this.ollamaUrl}/api/chat`, {
          model: model || 'llama3',
          messages: messages,
          stream: false,
        }),
      );

      const aiText = response.data.message?.content || 'No response from AI';

      // Parse AI response to match Flutter expectations if needed
      // Flutter expects: { response, followUps, calmScore, focus, practice }
      // Since we are using a raw LLM, we might need to prompt it to return JSON or parse the text.
      // For now, let's return a basic structure wrapping the text.
      
      return {
        response: aiText,
        followUps: ['Cuéntame más', 'Gracias', 'Necesito ayuda'], // Static for now
        calmScore: 0.5,
        focus: 'Conversación',
        practice: 'Escucha activa',
      };

    } catch (error) {
      this.logger.error('Error calling Ollama', error);
      // Fallback response if Ollama fails
      return {
        response: 'Lo siento, no puedo conectar con mi cerebro en este momento. ¿Podemos hablar más tarde?',
        followUps: [],
        calmScore: 0,
        focus: 'Error de conexión',
        practice: 'Intenta nuevamente',
      };
    }
  }
}
