"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DiaryService = void 0;
const common_1 = require("@nestjs/common");
let DiaryService = class DiaryService {
    constructor() {
        this.entries = [
            {
                id: '1',
                title: 'Agradecimiento matinal',
                body: 'Hoy me sentí agradecido por el apoyo de mis amigos. Practiqué respiraciones y comencé el día con calma.',
                mood: 'Alegre',
                createdAt: new Date().toISOString(),
                tags: ['agradecimiento', 'respiración'],
            },
        ];
    }
    findAll(userId) {
        return this.entries.map((entry) => ({ ...entry, userId }));
    }
    create(userId, dto) {
        var _a, _b;
        const entry = {
            id: (Date.now()).toString(),
            title: dto.title,
            body: dto.body,
            mood: dto.mood,
            createdAt: ((_a = dto.createdAt) !== null && _a !== void 0 ? _a : new Date()).toISOString(),
            tags: (_b = dto.tags) !== null && _b !== void 0 ? _b : [],
        };
        this.entries = [entry, ...this.entries];
        return { ...entry, userId };
    }
    update(userId, id, dto) {
        var _a, _b;
        const index = this.entries.findIndex((entry) => entry.id === id);
        if (index < 0)
            throw new common_1.NotFoundException('Diary entry not found');
        const updated = {
            ...this.entries[index],
            ...dto,
            createdAt: (_b = (_a = dto.createdAt) === null || _a === void 0 ? void 0 : _a.toISOString()) !== null && _b !== void 0 ? _b : this.entries[index].createdAt,
        };
        this.entries[index] = updated;
        return { ...updated, userId };
    }
    remove(userId, id) {
        const index = this.entries.findIndex((entry) => entry.id === id);
        if (index < 0)
            throw new common_1.NotFoundException('Diary entry not found');
        const [removed] = this.entries.splice(index, 1);
        return { ...removed, userId };
    }
};
exports.DiaryService = DiaryService;
exports.DiaryService = DiaryService = __decorate([
    (0, common_1.Injectable)()
], DiaryService);
//# sourceMappingURL=diary.service.js.map