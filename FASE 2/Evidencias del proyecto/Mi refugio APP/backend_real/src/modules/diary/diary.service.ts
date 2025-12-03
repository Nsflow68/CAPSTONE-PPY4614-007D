import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DiaryEntry } from './entities/diary-entry.entity';
import { v4 as uuidv4 } from 'uuid';

export class CreateDiaryEntryDto {
    title: string;
    content: string;
    mood: string;
    score: number;
    moodText?: string;
    emotions: string[];
    tags: string[];
    date: string; // ISO date string
}

@Injectable()
export class DiaryService {
    constructor(
        @InjectRepository(DiaryEntry)
        private diaryRepository: Repository<DiaryEntry>,
    ) { }

    async findAllByUser(userId: string): Promise<DiaryEntry[]> {
        return this.diaryRepository.find({
            where: { userId },
            order: { createdAt: 'DESC' },
        });
    }

    async findOne(id: string, userId: string): Promise<DiaryEntry | null> {
        return this.diaryRepository.findOne({
            where: { id, userId },
        });
    }

    async create(userId: string, dto: CreateDiaryEntryDto): Promise<DiaryEntry> {
        const entry = this.diaryRepository.create({
            id: uuidv4(),
            ...dto,
            date: new Date(dto.date),
            userId,
            emotions: dto.emotions || [],
            tags: dto.tags || [],
        });

        return this.diaryRepository.save(entry);
    }

    async update(id: string, userId: string, dto: Partial<CreateDiaryEntryDto>): Promise<DiaryEntry> {
        const entry = await this.findOne(id, userId);
        if (!entry) {
            throw new Error('Entry not found');
        }

        Object.assign(entry, {
            ...dto,
            date: dto.date ? new Date(dto.date) : entry.date,
        });

        return this.diaryRepository.save(entry);
    }

    async delete(id: string, userId: string): Promise<void> {
        await this.diaryRepository.delete({ id, userId });
    }
}
