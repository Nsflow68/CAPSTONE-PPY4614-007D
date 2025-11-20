import { Injectable } from '@nestjs/common';
import { DiaryEntry as DiaryEntryModel, Prisma } from '@prisma/client';
import { randomUUID } from 'crypto';
import { DemoUserService } from '../common/demo-user.service';
import { PrismaService } from '../database/prisma.service';
import { DiaryEntryDto } from './dto/diary-entry.dto';
import { DiaryFilterDto } from './dto/diary-filter.dto';
import { CreateDiaryEntryDto } from './dto/create-diary-entry.dto';
import diaryReference from './diary.reference.json';

@Injectable()
export class DiaryService {
  private readonly dataset = diaryReference as { items: DiaryEntryDto[] };
  private entries: DiaryEntryDto[] = this.dataset.items.map((entry) => ({ ...entry }));

  constructor(
    private readonly prisma: PrismaService,
    private readonly demoUser: DemoUserService,
  ) {}

  async listEntries(filters: DiaryFilterDto) {
    if (this.prisma.isHealthy) {
      const userId = await this.demoUser.getUserId();
      const conditions: Prisma.DiaryEntryWhereInput[] = [{ userId }];

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

      const where: Prisma.DiaryEntryWhereInput = { AND: conditions };
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
      items = items.filter((entry) => entry.date >= filters.from!);
    }
    if (filters.to) {
      items = items.filter((entry) => entry.date <= filters.to!);
    }
    if (filters.mood) {
      items = items.filter((entry) => entry.mood.toLowerCase() === filters.mood!.toLowerCase());
    }

    return { total: items.length, items };
  }

  async createEntry(dto: CreateDiaryEntryDto) {
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

    const entry: DiaryEntryDto = {
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

  private mapFromModel(entry: DiaryEntryModel): DiaryEntryDto {
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

  private randomId() {
    return randomUUID();
  }
}
