import { Injectable, Logger } from '@nestjs/common';
import { HydrationLog } from '@prisma/client';
import { DemoUserService } from '../common/demo-user.service';
import { PrismaService } from '../database/prisma.service';
import { HydrationDailyIntakeDto } from './dto/hydration-intake.dto';
import { RegisterIntakeDto } from './dto/register-intake.dto';
import hydrationReference from './hydration.reference.json';

@Injectable()
export class HydrationService {
  private readonly logger = new Logger(HydrationService.name);
  private readonly goalMl = 2000;

  private readonly fallbackDataset = hydrationReference as {
    items: HydrationDailyIntakeDto[];
    averageMl: number;
  };
  private readonly fallbackItems: HydrationDailyIntakeDto[] = this.fallbackDataset.items.map(
    (item) => ({ ...item }),
  );

  constructor(
    private readonly prisma: PrismaService,
    private readonly demoUser: DemoUserService,
  ) {}

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
      return (
        summary.items.find((item) => item.date === todayKey) ??
        summary.items[summary.items.length - 1]
      );
    }

    const today = new Date().toISOString().substring(0, 10);
    return (
      this.fallbackItems.find((item) => item.date === today) ??
      this.fallbackItems[this.fallbackItems.length - 1]
    );
  }

  async registerIntake(dto: RegisterIntakeDto) {
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
      const record: HydrationDailyIntakeDto = {
        date: this.dateOnly(targetDate),
        totalMl,
        goalMl: this.goalMl,
        percentage: Number((totalMl / this.goalMl).toFixed(2)),
      };

      this.logger.log(
        `Registrados ${dto.amountMl} ml para ${record.date} (total ${record.totalMl} ml)`,
      );
      return { message: 'intake_registered', record };
    }

    const dateKey = dto.date ?? new Date().toISOString().substring(0, 10);
    const record = this.findOrCreateFallbackRecord(dateKey);

    record.totalMl += dto.amountMl;
    record.percentage = Number((record.totalMl / record.goalMl).toFixed(2));
    this.logger.log(`Registrados ${dto.amountMl} ml para ${dateKey} (total ${record.totalMl} ml)`);

    return { message: 'intake_registered', record };
  }

  private buildSummary(logs: HydrationLog[], rangeStart: Date) {
    const map = new Map<string, HydrationDailyIntakeDto>();
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

  private findOrCreateFallbackRecord(date: string) {
    const existing = this.fallbackItems.find((item) => item.date === date);
    if (existing) return existing;

    const record: HydrationDailyIntakeDto = {
      date,
      totalMl: 0,
      goalMl: this.goalMl,
      percentage: 0,
    };
    this.fallbackItems.push(record);
    return record;
  }

  private weekRange() {
    const today = new Date();
    const start = this.startOfDay(today);
    start.setDate(start.getDate() - 6);
    const end = this.endOfDay(today);
    return { start, end };
  }

  private startOfDay(date: Date) {
    const start = new Date(date);
    start.setHours(0, 0, 0, 0);
    return start;
  }

  private endOfDay(date: Date) {
    const end = new Date(date);
    end.setHours(23, 59, 59, 999);
    return end;
  }

  private dateOnly(date: Date) {
    return date.toISOString().substring(0, 10);
  }
}
