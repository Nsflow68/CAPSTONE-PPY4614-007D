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

export interface OllamaHealth {
  status: 'ok' | 'degraded';
  latencyMs: number;
  model: string;
  endpoint: string;
  detail?: string;
}

@Injectable()
export class OllamaService {
  private readonly logger = new Logger(OllamaService.name);
  private readonly baseUrl: string;
  private readonly model: string;

  constructor(
    private readonly http: HttpService,
    private readonly configService: ConfigService,
  ) {
    this.baseUrl = this.configService.get<string>('ollamaBaseUrl') ?? 'http://localhost:11434';
    this.model = this.configService.get<string>('ollamaModel') ?? 'llama3.2:3b-instruct-q4_K_M';
  }

  async generate(params: GenerateParams): Promise<GenerateResult> {
    const {
      prompt,
      system = 'Actúa como un acompañante emocional empático. Responde con calidez, escucha activa y ofrece sugerencias simples para manejar emociones como ansiedad, estrés o tristeza.',
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
      return {
        text,
        latencyMs: Date.now() - startedAt,
        model: this.model,
      };
    } catch (error) {
      this.logger.warn(`Fallo al invocar Ollama: ${error?.message ?? error}`);
      throw error;
    }
  }

  async checkHealth(timeoutMs = 2_000): Promise<OllamaHealth> {
    const startedAt = Date.now();
    try {
      await this.http.axiosRef.get(`${this.baseUrl}/api/tags`, { timeout: timeoutMs });
      return {
        status: 'ok',
        latencyMs: Date.now() - startedAt,
        model: this.model,
        endpoint: this.baseUrl,
      };
    } catch (error) {
      this.logger.warn(`Ollama no responde en ${this.baseUrl}: ${error?.message ?? error}`);
      return {
        status: 'degraded',
        latencyMs: Date.now() - startedAt,
        model: this.model,
        endpoint: this.baseUrl,
        detail: String(error?.message ?? error),
      };
    }
  }
}
