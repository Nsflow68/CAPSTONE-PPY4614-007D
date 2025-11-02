import { Injectable } from '@nestjs/common';

interface ChatMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  createdAt: string;
}

@Injectable()
export class ChatbotService {
  private readonly history: ChatMessage[] = [
    {
      id: '1',
      role: 'assistant',
      content: 'Hola, soy tu compañero emocional. ¿Cómo te sientes hoy?',
      createdAt: new Date().toISOString(),
    },
  ];

  getHistory(): ChatMessage[] {
    return this.history;
  }

  sendMessage(message: string): ChatMessage {
    const userMessage: ChatMessage = {
      id: Date.now().toString(),
      role: 'user',
      content: message,
      createdAt: new Date().toISOString(),
    };
    this.history.push(userMessage);

    const assistant: ChatMessage = {
      id: `${Date.now()}-assistant`,
      role: 'assistant',
      content: this.generateResponse(message),
      createdAt: new Date().toISOString(),
    };
    this.history.push(assistant);
    return assistant;
  }

  private generateResponse(message: string): string {
    const text = message.toLowerCase();
    if (text.includes('ansiedad')) {
      return 'Respira conmigo: inhala cuatro tiempos, mantén cuatro y exhala en seis. Puedes revisar la sección de Mindfulness para más ejercicios.';
    }
    if (text.includes('estres') || text.includes('estrés')) {
      return 'Te sugiero una pausa consciente. Escribe en tu diario qué detonó la sensación y prueba con la rutina de respiración 4-7-8.';
    }
    return 'Gracias por compartirlo. Estoy aquí para escucharte y darte recursos profesionales cuando lo necesites.';
  }
}
