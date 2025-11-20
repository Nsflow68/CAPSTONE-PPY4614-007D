import { DemoUserService } from '../common/demo-user.service';
import { PrismaService } from '../database/prisma.service';
import { DiaryEntryDto } from './dto/diary-entry.dto';
import { DiaryFilterDto } from './dto/diary-filter.dto';
import { CreateDiaryEntryDto } from './dto/create-diary-entry.dto';
export declare class DiaryService {
    private readonly prisma;
    private readonly demoUser;
    private readonly dataset;
    private entries;
    constructor(prisma: PrismaService, demoUser: DemoUserService);
    listEntries(filters: DiaryFilterDto): Promise<{
        total: number;
        items: DiaryEntryDto[];
    }>;
    createEntry(dto: CreateDiaryEntryDto): Promise<DiaryEntryDto>;
    private mapFromModel;
    private randomId;
}
