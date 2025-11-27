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
var HydrationService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.HydrationService = void 0;
const common_1 = require("@nestjs/common");
const demo_user_service_1 = require("../common/demo-user.service");
const prisma_service_1 = require("../database/prisma.service");
const hydration_reference_json_1 = __importDefault(require("./hydration.reference.json"));
let HydrationService = HydrationService_1 = class HydrationService {
    constructor(prisma, demoUser) {
        this.prisma = prisma;
        this.demoUser = demoUser;
        this.logger = new common_1.Logger(HydrationService_1.name);
        this.goalMl = 2000;
        this.fallbackDataset = hydration_reference_json_1.default;
        this.fallbackItems = this.fallbackDataset.items.map((item) => ({ ...item }));
    }
    async listWeeklyIntake() {
        if (this.prisma.isHealthy) {
            const userId = await this.demoUser.getUserId();
            const { start, end } = this.weekRange();
            const logs = await this.prisma.hydrationLog.findMany({
                where: { userId, date: { gte: start, lte: end } },
                orderBy: { date: 'asc' },
            });
            const items = this.buildSummary(logs, start);
            const averageMl = items.reduce((acc, item) => acc + item.totalMl, 0) / items.length || 0;
            return { items, averageMl };
        }
        const items = this.fallbackItems.map((item) => ({ ...item }));
        return { items, averageMl: this.fallbackDataset.averageMl };
    }
    async getTodayIntake() {
        if (this.prisma.isHealthy) {
            const summary = await this.listWeeklyIntake();
            const todayKey = this.dateOnly(new Date());
            return (summary.items.find((item) => item.date === todayKey) ??
                summary.items[summary.items.length - 1]);
        }
        const today = new Date().toISOString().substring(0, 10);
        return (this.fallbackItems.find((item) => item.date === today) ??
            this.fallbackItems[this.fallbackItems.length - 1]);
    }
    async registerIntake(dto) {
        if (this.prisma.isHealthy) {
            const userId = await this.demoUser.getUserId();
            const targetDate = dto.date ? new Date(dto.date) : new Date();
            await this.prisma.hydrationLog.create({
                data: {
                    userId,
                    amountMl: dto.amountMl,
                    date: targetDate,
                },
            });
            const start = this.startOfDay(targetDate);
            const end = this.endOfDay(targetDate);
            const result = await this.prisma.hydrationLog.aggregate({
                _sum: { amountMl: true },
                where: { userId, date: { gte: start, lte: end } },
            });
            const totalMl = result._sum.amountMl ?? 0;
            const record = {
                date: this.dateOnly(targetDate),
                totalMl,
                goalMl: this.goalMl,
                percentage: Number((totalMl / this.goalMl).toFixed(2)),
            };
            this.logger.log(`Registrados ${dto.amountMl} ml para ${record.date} (total ${record.totalMl} ml)`);
            return { message: 'intake_registered', record };
        }
        const dateKey = dto.date ?? new Date().toISOString().substring(0, 10);
        const record = this.findOrCreateFallbackRecord(dateKey);
        record.totalMl += dto.amountMl;
        record.percentage = Number((record.totalMl / record.goalMl).toFixed(2));
        this.logger.log(`Registrados ${dto.amountMl} ml para ${dateKey} (total ${record.totalMl} ml)`);
        return { message: 'intake_registered', record };
    }
    buildSummary(logs, rangeStart) {
        const map = new Map();
        for (let i = 0; i < 7; i++) {
            const day = new Date(rangeStart);
            day.setDate(rangeStart.getDate() + i);
            const key = this.dateOnly(day);
            map.set(key, {
                date: key,
                totalMl: 0,
                goalMl: this.goalMl,
                percentage: 0,
            });
        }
        logs.forEach((log) => {
            const key = this.dateOnly(log.date);
            const record = map.get(key);
            if (record) {
                record.totalMl += log.amountMl;
                record.percentage = Number((record.totalMl / record.goalMl).toFixed(2));
            }
        });
        return Array.from(map.values());
    }
    findOrCreateFallbackRecord(date) {
        const existing = this.fallbackItems.find((item) => item.date === date);
        if (existing)
            return existing;
        const record = {
            date,
            totalMl: 0,
            goalMl: this.goalMl,
            percentage: 0,
        };
        this.fallbackItems.push(record);
        return record;
    }
    weekRange() {
        const today = new Date();
        const start = this.startOfDay(today);
        start.setDate(start.getDate() - 6);
        const end = this.endOfDay(today);
        return { start, end };
    }
    startOfDay(date) {
        const start = new Date(date);
        start.setHours(0, 0, 0, 0);
        return start;
    }
    endOfDay(date) {
        const end = new Date(date);
        end.setHours(23, 59, 59, 999);
        return end;
    }
    dateOnly(date) {
        return date.toISOString().substring(0, 10);
    }
};
exports.HydrationService = HydrationService;
exports.HydrationService = HydrationService = HydrationService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        demo_user_service_1.DemoUserService])
], HydrationService);
//# sourceMappingURL=hydration.service.js.map