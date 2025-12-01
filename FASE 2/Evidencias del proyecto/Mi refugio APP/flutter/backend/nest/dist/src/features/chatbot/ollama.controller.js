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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OllamaController = void 0;
const common_1 = require("@nestjs/common");
const ollama_service_1 = require("./ollama.service");
let OllamaController = class OllamaController {
    constructor(ollamaService) {
        this.ollamaService = ollamaService;
    }
    async health() {
        const status = await this.ollamaService.checkHealth();
        return { data: status };
    }
    async generate(message) {
        if (!message || message.trim() === '') {
            throw new common_1.HttpException('Message is required', common_1.HttpStatus.BAD_REQUEST);
        }
        const result = await this.ollamaService.generate({ prompt: message });
        return {
            data: {
                text: result.text,
                latencyMs: result.latencyMs,
                model: result.model,
            },
        };
    }
};
exports.OllamaController = OllamaController;
__decorate([
    (0, common_1.Get)('health'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], OllamaController.prototype, "health", null);
__decorate([
    (0, common_1.Post)('message'),
    __param(0, (0, common_1.Body)('message')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], OllamaController.prototype, "generate", null);
exports.OllamaController = OllamaController = __decorate([
    (0, common_1.Controller)('chatbot'),
    __metadata("design:paramtypes", [ollama_service_1.OllamaService])
], OllamaController);
//# sourceMappingURL=ollama.controller.js.map