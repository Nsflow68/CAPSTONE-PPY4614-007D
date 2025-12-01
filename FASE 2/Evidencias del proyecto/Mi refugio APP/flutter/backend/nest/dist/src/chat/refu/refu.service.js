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
var RefuService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.RefuService = void 0;
const common_1 = require("@nestjs/common");
const llm_local_service_1 = require("./llm-local.service");
let RefuService = RefuService_1 = class RefuService {
    constructor(llmLocal) {
        this.llmLocal = llmLocal;
        this.logger = new common_1.Logger(RefuService_1.name);
        this.assistantPersona = 'Eres Refu, un acompañante emocional amable creado para Mi Refugio. ' +
            'Responde en español neutro de Chile, con empatía y calidez. ' +
            'Evita dar diagnósticos médicos. ' +
            'Sugiere recursos prácticos como ejercicios de respiración, escribir en el diario, ' +
            'y buscar ayuda profesional cuando sea necesario. ' +
            'Tu objetivo es acompañar, escuchar activamente y ofrecer apoyo emocional.';
    }
    async sendMessage(dto) {
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
        }
        catch (error) {
            this.logger.warn(`Fallo llamado a LLM local: ${error?.message ?? error}`, error?.stack);
            const metrics = this.createMetrics('fallback', startedAt);
            return {
                reply: this.fallbackAnswer(dto.message),
                provider: 'fallback',
                metrics,
            };
        }
    }
    async health() {
        return this.llmLocal.checkHealth();
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
exports.RefuService = RefuService;
exports.RefuService = RefuService = RefuService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [llm_local_service_1.LlmLocalService])
], RefuService);
//# sourceMappingURL=refu.service.js.map