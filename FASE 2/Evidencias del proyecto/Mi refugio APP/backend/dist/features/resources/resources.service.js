"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ResourcesService = void 0;
const common_1 = require("@nestjs/common");
let ResourcesService = class ResourcesService {
    constructor() {
        this.resources = [
            {
                id: 'fono-salud',
                title: 'Fono Salud Responde',
                subtitle: 'L�nea 24/7 del Ministerio de Salud',
                category: 'Urgencia',
                description: 'Atenci�n gratuita en crisis, contenci�n emocional inmediata y derivaci�n con profesionales acreditados.',
                contact: '600 360 7777',
                website: 'https://www.gob.cl/saludresponde',
            },
            {
                id: 'mindfulness-uc',
                title: 'Mindfulness UC',
                subtitle: 'Programa Pontificia Universidad Cat�lica',
                category: 'Mindfulness',
                description: 'Cursos, c�psulas y talleres respaldados por especialistas para incorporar atenci�n plena a la rutina diaria.',
                website: 'https://mindfulness.uc.cl/recursos/',
            },
            {
                id: 'elige-vivir-sano',
                title: 'Elige Vivir Sano - Hidrataci�n',
                subtitle: 'Gobierno de Chile',
                category: 'Hidrataci�n',
                description: 'Gu�a oficial sobre consumo de agua, infusiones saludables y recordatorios diarios para toda la familia.',
                website: 'https://eligevivirsano.gob.cl/hidratacion',
            },
        ];
    }
    findAll(category) {
        if (!category) {
            return this.resources;
        }
        const normalized = category.toLowerCase();
        return this.resources.filter((resource) => resource.category.toLowerCase() === normalized);
    }
};
exports.ResourcesService = ResourcesService;
exports.ResourcesService = ResourcesService = __decorate([
    (0, common_1.Injectable)()
], ResourcesService);
//# sourceMappingURL=resources.service.js.map