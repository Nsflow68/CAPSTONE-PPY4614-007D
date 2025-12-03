import { Controller, Get, Post, Body, Request } from '@nestjs/common';
import { RewardsService } from './rewards.service';

@Controller('rewards')
export class RewardsController {
    constructor(private readonly rewardsService: RewardsService) { }

    @Get()
    async getRewards(@Request() req) {
        const userId = req.user?.id;
        if (!userId) return {};
        return this.rewardsService.getRewards(userId);
    }

    // Endpoint to manually add points (for testing or specific actions)
    @Post('add-points')
    async addPoints(@Body() body: { points: number }, @Request() req) {
        const userId = req.user?.id;
        return this.rewardsService.addPoints(userId, body.points);
    }
}
