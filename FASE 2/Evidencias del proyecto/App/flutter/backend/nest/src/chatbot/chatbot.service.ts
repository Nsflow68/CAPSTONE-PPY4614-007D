import { Injectable, Logger } from '@nestjs/common';
import { SendMessageDto } from './dto/send-message.dto';
import { ChatResponseDto } from './dto/chat-response.dto';
import { OllamaService, OllamaHealth } from './ollama.service';

@Injectable()
export class ChatbotService {
  private readonly logger = new Logger(ChatbotService.name);
  private readonly assistantPersona =
    'Eres Refu, un acompañante emocional amable creado para Mi Refugio. ' +
    'Responde en español neutro, con empatía, evita diagnósticos médicos y sugiere recursos prácticos de respiración, diario y profesionales.';

  constructor(private readonly ollama: OllamaService) {}

  async sendMessage(dto: SendMessageDto): Promise<ChatResponseDto> {
    const prompt = this.buildPrompt(dto);
    const startedAt = Date.now();
    try {
      const result = await this.ollama.generate({
        prompt,
        system: this.assistantPersona,
      });

      const reply = this.normalizeResponse(result.text);
      const metrics = this.createMetrics('ollama', startedAt, result.model);
      return { reply, provider: 'ollama', metrics };
    } catch (error) {
      this.logger.warn(`Fallo llamado a Ollama: ${error?.message ?? error}`, error?.stack);
      const metrics = this.createMetrics('fallback', startedAt);
      return {
        reply: this.fallbackAnswer(dto.message),
        provider: 'fallback',
        metrics,
      };
    }
  }

  async health(): Promise<OllamaHealth> {
    return this.ollama.checkHealth();
  }

  private buildPrompt(dto: SendMessageDto) {
    const context = dto.context?.length
      ? dto.context.map((msg) => `${msg.role.toUpperCase()}: ${msg.content}`).join('\n')
      : '';

    if (!context) {
      return dto.message.trim();
    }
    return `${context}\nUSER: ${dto.message.trim()}\nASSISTANT:`;
  }

  private normalizeResponse(raw: unknown) {
    if (typeof raw === 'string') {
      return raw.trim().length ? raw.trim() : this.genericAck();
    }
    return this.genericAck();
  }

  private fallbackAnswer(message: string) {
    if (message.toLowerCase().includes('ansiedad')) {
      return 'Respiremos juntos: inhala 4 segundos, mantén 4 y exhala en 6. Estoy aquí contigo.';
    }
    if (message.toLowerCase().includes('estrés') || message.toLowerCase().includes('estres')) {
      return 'Tomemos una pausa. Observa tu respiración y anota en tu diario qué detonó esa emoción.';
    }
    return this.genericAck();
  }

  private genericAck() {
    return 'Gracias por compartirlo. Estoy aquí para acompañarte y darte recursos cuando lo necesites.';
  }

  private createMetrics(provider: string, startedAt: number, model?: string) {
    return {
      latencyMs: Date.now() - startedAt,
      provider,
      model,
      timestamp: new Date().toISOString(),
    };
  }
}
