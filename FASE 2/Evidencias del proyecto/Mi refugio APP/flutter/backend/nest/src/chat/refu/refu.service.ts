import { Injectable, Logger } from '@nestjs/common';
import { SendMessageDto } from '../dto/send-message.dto';
import { ChatResponseDto } from '../dto/chat-response.dto';
import { LlmLocalService, LlmHealth } from './llm-local.service';

/**
 * Servicio principal de Refu - el asistente emocional de Mi Refugio.
 * Gestiona las conversaciones con usuarios utilizando el LLM local.
 */
@Injectable()
export class RefuService {
  private readonly logger = new Logger(RefuService.name);
  private readonly assistantPersona =
    'Eres Refu, un acompañante emocional amable creado para Mi Refugio. ' +
    'Responde en español neutro de Chile, con empatía y calidez. ' +
    'Evita dar diagnósticos médicos. ' +
    'Sugiere recursos prácticos como ejercicios de respiración, escribir en el diario, ' +
    'y buscar ayuda profesional cuando sea necesario. ' +
    'Tu objetivo es acompañar, escuchar activamente y ofrecer apoyo emocional.';

  constructor(private readonly llmLocal: LlmLocalService) {}

  /**
   * Procesa un mensaje del usuario y genera una respuesta empática
   */
  async sendMessage(dto: SendMessageDto): Promise<ChatResponseDto> {
    const prompt = this.buildPrompt(dto);
    const startedAt = Date.now();

    try {
      const result = await this.llmLocal.generate({
        prompt,
        system: this.assistantPersona,
      });

      const reply = this.normalizeResponse(result.text);
      const metrics = this.createMetrics('llm-local', startedAt, result.model);

      return { reply, provider: 'llm-local', metrics };
    } catch (error) {
      this.logger.warn(`Fallo llamado a LLM local: ${error?.message ?? error}`, error?.stack);
      const metrics = this.createMetrics('fallback', startedAt);

      return {
        reply: this.fallbackAnswer(dto.message),
        provider: 'fallback',
        metrics,
      };
    }
  }

  /**
   * Verifica el estado del servicio de LLM local
   */
  async health(): Promise<LlmHealth> {
    return this.llmLocal.checkHealth();
  }

  /**
   * Construye el prompt completo con contexto si existe
   */
  private buildPrompt(dto: SendMessageDto): string {
    const context = dto.context?.length
      ? dto.context.map((msg) => `${msg.role.toUpperCase()}: ${msg.content}`).join('\n')
      : '';

    if (!context) {
      return dto.message.trim();
    }

    return `${context}\nUSER: ${dto.message.trim()}\nASSISTANT:`;
  }

  /**
   * Normaliza y valida la respuesta del LLM
   */
  private normalizeResponse(raw: unknown): string {
    if (typeof raw === 'string') {
      return raw.trim().length ? raw.trim() : this.genericAck();
    }
    return this.genericAck();
  }

  /**
   * Proporciona respuestas de respaldo cuando el LLM no está disponible
   */
  private fallbackAnswer(message: string): string {
    const lowerMessage = message.toLowerCase();

    if (lowerMessage.includes('ansiedad')) {
      return 'Respiremos juntos: inhala durante 4 segundos, mantén el aire 4 segundos y exhala en 6 segundos. Estoy aquí contigo.';
    }

    if (lowerMessage.includes('estrés') || lowerMessage.includes('estres')) {
      return 'Tomemos una pausa. Observa tu respiración y anota en tu diario qué detonó esa emoción. Puede ayudarte a procesarla.';
    }

    if (lowerMessage.includes('tristeza') || lowerMessage.includes('triste')) {
      return 'Es válido sentir tristeza. ¿Te gustaría escribir sobre lo que sientes en tu diario? A veces ayuda expresar nuestras emociones.';
    }

    if (lowerMessage.includes('ayuda') || lowerMessage.includes('apoyo')) {
      return 'Estoy aquí para acompañarte. También puedes explorar los recursos profesionales disponibles en la app si necesitas apoyo especializado.';
    }

    return this.genericAck();
  }

  /**
   * Mensaje genérico de reconocimiento
   */
  private genericAck(): string {
    return 'Gracias por compartirlo. Estoy aquí para acompañarte y darte recursos cuando lo necesites.';
  }

  /**
   * Crea métricas de la conversación
   */
  private createMetrics(provider: string, startedAt: number, model?: string) {
    return {
      latencyMs: Date.now() - startedAt,
      provider,
      model,
      timestamp: new Date().toISOString(),
    };
  }
}
