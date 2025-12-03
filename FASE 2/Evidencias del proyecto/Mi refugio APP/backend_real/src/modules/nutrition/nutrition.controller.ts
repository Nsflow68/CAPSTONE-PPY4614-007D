import { Controller, Get, Post, Body, Query, Request } from '@nestjs/common';
import { NutritionService } from './nutrition.service';

@Controller('nutrition')
export class NutritionController {
    constructor(private readonly nutritionService: NutritionService) { }

    @Post()
    async logMeal(@Body() body: any, @Request() req) {
        const userId = req.user?.id || body.userId;
        return this.nutritionService.logMeal(userId, body);
    }

    @Get('daily')
    async getDailySummary(@Query('date') date: string, @Request() req) {
        const userId = req.user?.id;
        if (!userId) return {};
        // Default to today if no date provided
        const targetDate = date || new Date().toISOString().split('T')[0];
        return this.nutritionService.getDailySummary(userId, targetDate);
    }
}
