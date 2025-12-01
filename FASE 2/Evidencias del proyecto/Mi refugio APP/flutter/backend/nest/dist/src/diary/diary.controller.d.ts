import { DiaryService } from './diary.service';
import { DiaryFilterDto } from './dto/diary-filter.dto';
import { CreateDiaryEntryDto } from './dto/create-diary-entry.dto';
export declare class DiaryController {
    private readonly diaryService;
    constructor(diaryService: DiaryService);
    listEntries(filters: DiaryFilterDto): Promise<{
        total: number;
        items: import("./dto/diary-entry.dto").DiaryEntryDto[];
    }>;
    createEntry(dto: CreateDiaryEntryDto): Promise<import("./dto/diary-entry.dto").DiaryEntryDto>;
}
