import { OllamaService } from './ollama.service';
export declare class OllamaController {
    private readonly ollamaService;
    constructor(ollamaService: OllamaService);
    health(): Promise<{
        data: import("./ollama.service").OllamaHealth;
    }>;
    generate(message: string): Promise<{
        data: {
            text: string;
            latencyMs: number;
            model: string;
        };
    }>;
}
