import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateDiaryEntryDto } from './dto/create-diary-entry.dto';
import { UpdateDiaryEntryDto } from './dto/update-diary-entry.dto';

export interface DiaryEntry {
  id: string;
  title: string;
  body: string;
  mood: string;
  createdAt: string;
  tags: string[];
}

@Injectable()
export class DiaryService {
  private entries: DiaryEntry[] = [
    {
      id: '1',
      title: 'Agradecimiento matinal',
      body:
        'Hoy me sentí agradecido por el apoyo de mis amigos. Practiqué respiraciones y comencé el día con calma.',
      mood: 'Alegre',
      createdAt: new Date().toISOString(),
      tags: ['agradecimiento', 'respiración'],
    },
  ];

  findAll(userId: string) {
    return this.entries.map((entry) => ({ ...entry, userId }));
  }

  create(userId: string, dto: CreateDiaryEntryDto) {
    const entry: DiaryEntry = {
      id: (Date.now()).toString(),
      title: dto.title,
      body: dto.body,
      mood: dto.mood,
      createdAt: (dto.createdAt ?? new Date()).toISOString(),
      tags: dto.tags ?? [],
    };
    this.entries = [entry, ...this.entries];
    return { ...entry, userId };
  }

  update(userId: string, id: string, dto: UpdateDiaryEntryDto) {
    const index = this.entries.findIndex((entry) => entry.id === id);
    if (index < 0) throw new NotFoundException('Diary entry not found');
    const updated: DiaryEntry = {
      ...this.entries[index],
      ...dto,
      createdAt: dto.createdAt?.toISOString() ?? this.entries[index].createdAt,
    };
    this.entries[index] = updated;
    return { ...updated, userId };
  }

  remove(userId: string, id: string) {
    const index = this.entries.findIndex((entry) => entry.id === id);
    if (index < 0) throw new NotFoundException('Diary entry not found');
    const [removed] = this.entries.splice(index, 1);
    return { ...removed, userId };
  }
}
