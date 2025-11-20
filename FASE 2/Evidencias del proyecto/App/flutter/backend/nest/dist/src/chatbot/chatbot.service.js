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
var ChatbotService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChatbotService = void 0;
const common_1 = require("@nestjs/common");
const ollama_service_1 = require("./ollama.service");
let ChatbotService = ChatbotService_1 = class ChatbotService {
    constructor(ollama) {
        this.ollama = ollama;
        this.logger = new common_1.Logger(ChatbotService_1.name);
        this.assistantPersona = 'Eres Refu, un acompañante emocional amable creado para Mi Refugio. ' +
            'Responde en español neutro, con empatía, evita diagnósticos médicos y sugiere recursos prácticos de respiración, diario y profesionales.';
    }
    async sendMessage(dto) {
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
        }
        catch (error) {
            this.logger.warn(`Fallo llamado a Ollama: ${error?.message ?? error}`, error?.stack);
            const metrics = this.createMetrics('fallback', startedAt);
            return {
                reply: this.fallbackAnswer(dto.message),
                provider: 'fallback',
                metrics,
            };
        }
    }
    async health() {
        return this.ollama.checkHealth();
    }
    buildPrompt(dto) {
        const context = dto.context?.length
            ? dto.context.map((msg) => `${msg.role.toUpperCase()}: ${msg.content}`).join('\n')
            : '';
        if (!context) {
            return dto.message.trim();
        }
        return `${context}\nUSER: ${dto.message.trim()}\nASSISTANT:`;
    }
    normalizeResponse(raw) {
        if (typeof raw === 'string') {
            return raw.trim().length ? raw.trim() : this.genericAck();
        }
        return this.genericAck();
    }
    fallbackAnswer(message) {
        if (message.toLowerCase().includes('ansiedad')) {
            return 'Respiremos juntos: inhala 4 segundos, mantén 4 y exhala en 6. Estoy aquí contigo.';
        }
        if (message.toLowerCase().includes('estrés') || message.toLowerCase().includes('estres')) {
            return 'Tomemos una pausa. Observa tu respiración y anota en tu diario qué detonó esa emoción.';
        }
        return this.genericAck();
    }
    genericAck() {
        return 'Gracias por compartirlo. Estoy aquí para acompañarte y darte recursos cuando lo necesites.';
    }
    createMetrics(provider, startedAt, model) {
        return {
            latencyMs: Date.now() - startedAt,
            provider,
            model,
            timestamp: new Date().toISOString(),
        };
    }
};
exports.ChatbotService = ChatbotService;
exports.ChatbotService = ChatbotService = ChatbotService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [ollama_service_1.OllamaService])
], ChatbotService);
//# sourceMappingURL=chatbot.service.js.map