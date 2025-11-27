import { DemoUserService } from '../common/demo-user.service';
import { PrismaService } from '../database/prisma.service';
import { HydrationDailyIntakeDto } from './dto/hydration-intake.dto';
import { RegisterIntakeDto } from './dto/register-intake.dto';
export declare class HydrationService {
    private readonly prisma;
    private readonly demoUser;
    private readonly logger;
    private readonly goalMl;
    private readonly fallbackDataset;
    private readonly fallbackItems;
    constructor(prisma: PrismaService, demoUser: DemoUserService);
    listWeeklyIntake(): Promise<{
        items: HydrationDailyIntakeDto[];
        averageMl: number;
    }>;
    getTodayIntake(): Promise<HydrationDailyIntakeDto>;
    registerIntake(dto: RegisterIntakeDto): Promise<{
        message: string;
        record: HydrationDailyIntakeDto;
    }>;
    private buildSummary;
    private findOrCreateFallbackRecord;
    private weekRange;
    private startOfDay;
    private endOfDay;
    private dateOnly;
}
