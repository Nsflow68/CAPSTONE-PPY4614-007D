import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { HydrationLog } from './entities/hydration.entity';

@Injectable()
export class HydrationService {
    constructor(
        @InjectRepository(HydrationLog)
        private hydrationRepository: Repository<HydrationLog>,
    ) { }

    async logIntake(userId: string, amountMl: number, date: string) {
        const log = this.hydrationRepository.create({
            userId,
            amountMl,
            date,
        });
        return this.hydrationRepository.save(log);
    }

    async getWeeklySummary(userId: string) {
        const today = new Date();
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(today.getDate() - 7);

        // Simple query for now, we can refine the date range logic
        const logs = await this.hydrationRepository.find({
            where: {
                userId,
                // We might need to handle date comparison carefully depending on DB
                // For now, let's just get all logs for the user and filter/group in JS if needed, 
                // or rely on the frontend to filter. 
                // Better: Query last 7 days.
            },
            order: { date: 'ASC' }
        });

        // Group by date
        const summary = {};
        logs.forEach(log => {
            // Ensure date string format
            const dateStr = typeof log.date === 'string' ? log.date : (log.date as Date).toISOString().split('T')[0];
            if (!summary[dateStr]) {
                summary[dateStr] = 0;
            }
            summary[dateStr] += log.amountMl;
        });

        return Object.entries(summary).map(([date, totalMl]) => ({
            date,
            totalMl,
            goalMl: 2000 // Hardcoded goal for now
        }));
    }
}
