import { DiaryService } from './diary.service';
import { CreateDiaryEntryDto } from './dto/create-diary-entry.dto';
import { UpdateDiaryEntryDto } from './dto/update-diary-entry.dto';
export declare class DiaryController {
    private readonly diaryService;
    constructor(diaryService: DiaryService);
    private readonly mockUserId;
    findAll(): {
        userId: string;
        id: string;
        title: string;
        body: string;
        mood: string;
        createdAt: string;
        tags: string[];
    }[];
    create(dto: CreateDiaryEntryDto): {
        userId: string;
        id: string;
        title: string;
        body: string;
        mood: string;
        createdAt: string;
        tags: string[];
    };
    update(id: string, dto: UpdateDiaryEntryDto): {
        userId: string;
        id: string;
        title: string;
        body: string;
        mood: string;
        createdAt: string;
        tags: string[];
    };
    remove(id: string): {
        userId: string;
        id: string;
        title: string;
        body: string;
        mood: string;
        createdAt: string;
        tags: string[];
    };
}
