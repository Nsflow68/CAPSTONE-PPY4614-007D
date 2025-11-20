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
export declare class DiaryService {
    private entries;
    findAll(userId: string): {
        userId: string;
        id: string;
        title: string;
        body: string;
        mood: string;
        createdAt: string;
        tags: string[];
    }[];
    create(userId: string, dto: CreateDiaryEntryDto): {
        userId: string;
        id: string;
        title: string;
        body: string;
        mood: string;
        createdAt: string;
        tags: string[];
    };
    update(userId: string, id: string, dto: UpdateDiaryEntryDto): {
        userId: string;
        id: string;
        title: string;
        body: string;
        mood: string;
        createdAt: string;
        tags: string[];
    };
    remove(userId: string, id: string): {
        userId: string;
        id: string;
        title: string;
        body: string;
        mood: string;
        createdAt: string;
        tags: string[];
    };
}
