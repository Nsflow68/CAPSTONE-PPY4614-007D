import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { NutritionLog } from './entities/nutrition.entity';

@Injectable()
export class NutritionService {
    constructor(
        @InjectRepository(NutritionLog)
        private nutritionRepository: Repository<NutritionLog>,
    ) { }

    async logMeal(userId: string, data: Partial<NutritionLog>) {
        const log = this.nutritionRepository.create({
            ...data,
            userId,
        });
        return this.nutritionRepository.save(log);
    }

    async getDailySummary(userId: string, date: string) {
        const logs = await this.nutritionRepository.find({
            where: {
                userId,
                date,
            },
        });

        // Calculate totals
        const totals = logs.reduce(
            (acc, log) => ({
                calories: acc.calories + log.calories,
                protein: acc.protein + log.protein,
                carbs: acc.carbs + log.carbs,
                fat: acc.fat + log.fat,
            }),
            { calories: 0, protein: 0, carbs: 0, fat: 0 },
        );

        return {
            date,
            totals,
            logs,
        };
    }
}
