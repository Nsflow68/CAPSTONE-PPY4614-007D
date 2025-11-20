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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DiaryService = void 0;
const common_1 = require("@nestjs/common");
const crypto_1 = require("crypto");
const demo_user_service_1 = require("../common/demo-user.service");
const prisma_service_1 = require("../database/prisma.service");
const diary_reference_json_1 = __importDefault(require("./diary.reference.json"));
let DiaryService = class DiaryService {
    constructor(prisma, demoUser) {
        this.prisma = prisma;
        this.demoUser = demoUser;
        this.dataset = diary_reference_json_1.default;
        this.entries = this.dataset.items.map((entry) => ({ ...entry }));
    }
    async listEntries(filters) {
        if (this.prisma.isHealthy) {
            const userId = await this.demoUser.getUserId();
            const conditions = [{ userId }];
            if (filters.from) {
                conditions.push({ date: { gte: new Date(filters.from) } });
            }
            if (filters.to) {
                conditions.push({ date: { lte: new Date(filters.to) } });
            }
            if (filters.mood) {
                conditions.push({
                    mood: { equals: filters.mood, mode: 'insensitive' },
                });
            }
            const where = { AND: conditions };
            const [items, total] = await this.prisma.$transaction([
                this.prisma.diaryEntry.findMany({
                    where,
                    orderBy: { date: 'desc' },
                }),
                this.prisma.diaryEntry.count({ where }),
            ]);
            return {
                total,
                items: items.map((entry) => this.mapFromModel(entry)),
            };
        }
        let items = [...this.entries];
        if (filters.from) {
            items = items.filter((entry) => entry.date >= filters.from);
        }
        if (filters.to) {
            items = items.filter((entry) => entry.date <= filters.to);
        }
        if (filters.mood) {
            items = items.filter((entry) => entry.mood.toLowerCase() === filters.mood.toLowerCase());
        }
        return { total: items.length, items };
    }
    async createEntry(dto) {
        if (this.prisma.isHealthy) {
            const userId = await this.demoUser.getUserId();
            const entry = await this.prisma.diaryEntry.create({
                data: {
                    userId,
                    title: dto.title,
                    content: dto.content,
                    mood: dto.mood,
                    score: dto.score,
                    moodText: dto.moodText,
                    date: new Date(dto.date),
                    emotions: dto.emotions,
                    tags: dto.tags,
                },
            });
            return this.mapFromModel(entry);
        }
        const entry = {
            id: this.randomId(),
            title: dto.title,
            content: dto.content,
            mood: dto.mood,
            score: dto.score,
            moodText: dto.moodText,
            date: dto.date,
            createdAt: new Date().toISOString(),
            emotions: dto.emotions,
            tags: dto.tags,
        };
        this.entries = [entry, ...this.entries];
        return entry;
    }
    mapFromModel(entry) {
        return {
            id: entry.id,
            title: entry.title,
            content: entry.content,
            mood: entry.mood,
            score: entry.score,
            moodText: entry.moodText ?? '',
            date: entry.date.toISOString().substring(0, 10),
            createdAt: entry.createdAt.toISOString(),
            emotions: entry.emotions,
            tags: entry.tags,
        };
    }
    randomId() {
        return (0, crypto_1.randomUUID)();
    }
};
exports.DiaryService = DiaryService;
exports.DiaryService = DiaryService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        demo_user_service_1.DemoUserService])
], DiaryService);
//# sourceMappingURL=diary.service.js.map