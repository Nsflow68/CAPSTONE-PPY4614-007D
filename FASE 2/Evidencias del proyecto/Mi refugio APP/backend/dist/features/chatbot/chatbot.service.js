"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChatbotService = void 0;
const common_1 = require("@nestjs/common");
let ChatbotService = class ChatbotService {
    constructor() {
        this.history = [
            {
                id: '1',
                role: 'assistant',
                content: 'Hola, soy tu compañero emocional. ¿Cómo te sientes hoy?',
                createdAt: new Date().toISOString(),
            },
        ];
    }
    getHistory() {
        return this.history;
    }
    sendMessage(message) {
        const userMessage = {
            id: Date.now().toString(),
            role: 'user',
            content: message,
            createdAt: new Date().toISOString(),
        };
        this.history.push(userMessage);
        const assistant = {
            id: `${Date.now()}-assistant`,
            role: 'assistant',
            content: this.generateResponse(message),
            createdAt: new Date().toISOString(),
        };
        this.history.push(assistant);
        return assistant;
    }
    generateResponse(message) {
        const text = message.toLowerCase();
        if (text.includes('ansiedad')) {
            return 'Respira conmigo: inhala cuatro tiempos, mantén cuatro y exhala en seis. Puedes revisar la sección de Mindfulness para más ejercicios.';
        }
        if (text.includes('estres') || text.includes('estrés')) {
            return 'Te sugiero una pausa consciente. Escribe en tu diario qué detonó la sensación y prueba con la rutina de respiración 4-7-8.';
        }
        return 'Gracias por compartirlo. Estoy aquí para escucharte y darte recursos profesionales cuando lo necesites.';
    }
};
exports.ChatbotService = ChatbotService;
exports.ChatbotService = ChatbotService = __decorate([
    (0, common_1.Injectable)()
], ChatbotService);
//# sourceMappingURL=chatbot.service.js.map