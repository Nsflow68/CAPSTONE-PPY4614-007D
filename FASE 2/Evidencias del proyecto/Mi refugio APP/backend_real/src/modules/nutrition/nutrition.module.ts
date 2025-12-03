import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NutritionController } from './nutrition.controller';
import { NutritionService } from './nutrition.service';
import { NutritionLog } from './entities/nutrition.entity';

@Module({
    imports: [TypeOrmModule.forFeature([NutritionLog])],
    controllers: [NutritionController],
    providers: [NutritionService],
})
export class NutritionModule { }
