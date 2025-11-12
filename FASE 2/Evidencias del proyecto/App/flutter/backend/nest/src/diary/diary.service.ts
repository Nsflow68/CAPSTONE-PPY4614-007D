import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { DiaryEntryDto } from './dto/diary-entry.dto';
import { DiaryFilterDto } from './dto/diary-filter.dto';
import { CreateDiaryEntryDto } from './dto/create-diary-entry.dto';

@Injectable()
export class DiaryService {
  private entries: DiaryEntryDto[] = [
    {
      id: '1',
      title: 'Amanecer agradecido',
      content:
        'Inicié el día con respiraciones suaves y escribí tres cosas que valoro.',
      mood: 'Calma',
      score: 7,
      moodText: 'Te sentiste en calma y con gratitud.',
      date: this.dateOnly(-0),
      createdAt: new Date().toISOString(),
      emotions: ['Gratitud', 'Calma', 'Esperanza'],
      tags: ['gratitud', 'rutina']
    },
    {
      id: '2',
      title: 'Pequeños logros',
      content:
        'Cerré pendientes de la universidad y me premié con una caminata corta.',
      mood: 'Motivado',
      score: 8,
      moodText: 'Reconociste avances concretos.',
      date: this.dateOnly(-1),
      createdAt: this.isoHoursAgo(18),
      emotions: ['Orgullo', 'Motivación'],
      tags: ['estudios', 'logros']
    },
    {
      id: '3',
      title: 'Tarde desafiante',
      content:
        'Sentí ansiedad en una reunión difícil, pero pedí una pausa y hablé con sinceridad.',
      mood: 'Ansiedad',
      score: 4,
      moodText: 'Hubo tensión pero encontraste alivio.',
      date: this.dateOnly(-2),
      createdAt: this.isoHoursAgo(36),
      emotions: ['Ansiedad', 'Alivio'],
      tags: ['trabajo', 'autocuidado']
    }
  ];

  listEntries(filters: DiaryFilterDto) {
    let items = [...this.entries];
    if (filters.from) {
      items = items.filter((entry) => entry.date >= filters.from!);
    }
    if (filters.to) {
      items = items.filter((entry) => entry.date <= filters.to!);
    }
    if (filters.mood) {
      items = items.filter(
        (entry) => entry.mood.toLowerCase() === filters.mood!.toLowerCase()
      );
    }

    return {
      total: items.length,
      items
    };
  }

  createEntry(dto: CreateDiaryEntryDto) {
    const entry: DiaryEntryDto = {
      id: randomUUID(),
      title: dto.title,
      content: dto.content,
      mood: dto.mood,
      score: dto.score,
      moodText: dto.moodText,
      date: dto.date,
      createdAt: new Date().toISOString(),
      emotions: dto.emotions,
      tags: dto.tags
    };

    this.entries = [entry, ...this.entries];
    return entry;
  }

  private dateOnly(daysAgo: number) {
    const date = new Date();
    date.setDate(date.getDate() - daysAgo);
    return date.toISOString().substring(0, 10);
  }

  private isoHoursAgo(hours: number) {
    const date = new Date();
    date.setHours(date.getHours() - hours);
    return date.toISOString();
  }
}
