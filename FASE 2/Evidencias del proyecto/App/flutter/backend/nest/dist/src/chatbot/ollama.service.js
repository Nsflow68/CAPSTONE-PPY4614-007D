"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var OllamaService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.OllamaService = void 0;
const axios_1 = require("@nestjs/axios");
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
let OllamaService = OllamaService_1 = class OllamaService {
    constructor(http, configService) {
        this.http = http;
        this.configService = configService;
        this.logger = new common_1.Logger(OllamaService_1.name);
        this.baseUrl = this.configService.get('ollamaBaseUrl') ?? 'http://localhost:11434';
        this.model = this.configService.get('ollamaModel') ?? 'llama3.2:3b-instruct-q4_K_M';
    }
    async generate(params) {
        const { prompt, system, temperature = 0.4, timeoutMs = 60_000 } = params;
        const startedAt = Date.now();
        try {
            const response = await this.http.axiosRef.post(`${this.baseUrl}/api/generate`, {
                model: this.model,
                prompt,
                stream: false,
                system,
                options: {
                    temperature,
                },
            }, { timeout: timeoutMs });
            const text = typeof response.data?.response === 'string' ? response.data.response : '';
            return { text, latencyMs: Date.now() - startedAt, model: this.model };
        }
        catch (error) {
            this.logger.warn(`Fallo al invocar Ollama: ${error?.message ?? error}`);
            throw error;
        }
    }
    async checkHealth(timeoutMs = 2_000) {
        const startedAt = Date.now();
        try {
            await this.http.axiosRef.get(`${this.baseUrl}/api/tags`, { timeout: timeoutMs });
            return {
                status: 'ok',
                latencyMs: Date.now() - startedAt,
                model: this.model,
                endpoint: this.baseUrl,
            };
        }
        catch (error) {
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
};
exports.OllamaService = OllamaService;
exports.OllamaService = OllamaService = OllamaService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [axios_1.HttpService,
        config_1.ConfigService])
], OllamaService);
//# sourceMappingURL=ollama.service.js.map