import { HttpService } from '@nestjs/axios';
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
export declare class LlmLocalService {
    private readonly http;
    private readonly configService;
    private readonly logger;
    private readonly baseUrl;
    private readonly model;
    constructor(http: HttpService, configService: ConfigService);
    generate(params: GenerateParams): Promise<GenerateResult>;
    checkHealth(timeoutMs?: number): Promise<LlmHealth>;
}
export {};
