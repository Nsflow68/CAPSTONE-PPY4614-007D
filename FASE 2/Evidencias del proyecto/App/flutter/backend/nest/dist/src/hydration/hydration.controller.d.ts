import { HydrationService } from './hydration.service';
import { RegisterIntakeDto } from './dto/register-intake.dto';
export declare class HydrationController {
    private readonly hydrationService;
    constructor(hydrationService: HydrationService);
    getWeeklyIntake(): Promise<{
        items: import("./dto/hydration-intake.dto").HydrationDailyIntakeDto[];
        averageMl: number;
    }>;
    getToday(): Promise<import("./dto/hydration-intake.dto").HydrationDailyIntakeDto>;
    register(dto: RegisterIntakeDto): Promise<{
        message: string;
        record: import("./dto/hydration-intake.dto").HydrationDailyIntakeDto;
    }>;
}
