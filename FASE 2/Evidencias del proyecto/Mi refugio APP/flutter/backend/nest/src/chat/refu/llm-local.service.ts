import { HttpService } from '@nestjs/axios';
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

interface GenerateParams {
  prompt: string;
  system?: string;
  temperature?: number;
  timeoutMs?: number;
}

interface GenerateResult {
  text: string;
  latencyMs: number;
  model: string;
}

export interface LlmHealth {
  status: 'ok' | 'degraded';
  latencyMs: number;
  model: string;
  endpoint: string;
  detail?: string;
}

/**
 * Servicio para integración con LLM local (Ollama u otro modelo local).
 * Este servicio gestiona la comunicación con el modelo de lenguaje local
 * configurado en las variables de entorno.
 */
@Injectable()
export class LlmLocalService {
  private readonly logger = new Logger(LlmLocalService.name);
  private readonly baseUrl: string;
  private readonly model: string;

  constructor(
    private readonly http: HttpService,
    private readonly configService: ConfigService,
  ) {
    this.baseUrl = this.configService.get<string>('ollamaBaseUrl') ?? 'http://localhost:11434';
    this.model = this.configService.get<string>('ollamaModel') ?? 'llama3.2:3b-instruct-q4_K_M';
    this.logger.log(`LLM Local configurado: ${this.baseUrl} | Modelo: ${this.model}`);
  }

  /**
   * Genera una respuesta del modelo local basada en el prompt y sistema
   */
  async generate(params: GenerateParams): Promise<GenerateResult> {
    const {
      prompt,
      system = 'Actúa como un acompañante emocional empático y cálido llamado Refu. ' +
                'Responde en español de Chile, con calidez, escucha activa y ofrece sugerencias ' +
                'simples para manejar emociones como ansiedad, estrés o tristeza. ' +
                'No des diagnósticos médicos, solo acompañamiento y apoyo informativo.',
      temperature = 0.4,
      timeoutMs = 60_000,
    } = params;

    const startedAt = Date.now();

    try {
      const response = await this.http.axiosRef.post(
        `${this.baseUrl}/api/generate`,
        {
          model: this.model,
          prompt,
          stream: false,
          system,
          options: {
            temperature,
          },
        },
        { timeout: timeoutMs },
      );

      const text = typeof response.data?.response === 'string' ? response.data.response : '';
      const latencyMs = Date.now() - startedAt;

      return {
        text,
        latencyMs,
        model: this.model,
      };
    } catch (error) {
      const latencyMs = Date.now() - startedAt;
      this.logger.warn(`Fallo al invocar LLM local (${latencyMs}ms): ${error?.message ?? error}`);
      throw error;
    }
  }

  /**
   * Verifica el estado de salud del LLM local
   */
  async checkHealth(timeoutMs = 2_000): Promise<LlmHealth> {
    const startedAt = Date.now();
    try {
      await this.http.axiosRef.get(`${this.baseUrl}/api/tags`, { timeout: timeoutMs });
      const latencyMs = Date.now() - startedAt;

      return {
        status: 'ok',
        latencyMs,
        model: this.model,
        endpoint: this.baseUrl,
      };
    } catch (error) {
      const latencyMs = Date.now() - startedAt;
      this.logger.warn(`LLM local no responde en ${this.baseUrl} (${latencyMs}ms): ${error?.message ?? error}`);

      return {
        status: 'degraded',
        latencyMs,
        model: this.model,
        endpoint: this.baseUrl,
        detail: String(error?.message ?? error),
      };
    }
  }
}
