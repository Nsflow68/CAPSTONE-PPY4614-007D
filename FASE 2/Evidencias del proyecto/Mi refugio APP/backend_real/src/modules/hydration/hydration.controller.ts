import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { HydrationService } from './hydration.service';
// Assuming we have a JwtAuthGuard. If not, we'll need to find it.
// Usually it's in auth module.
// Let's check imports later. For now, I'll assume standard structure or no guard if I can't find it.
// But I need userId.
// I'll check auth module structure in a moment.

@Controller('hydration')
export class HydrationController {
    constructor(private readonly hydrationService: HydrationService) { }

    @Post()
    async logIntake(@Body() body: { amountMl: number; date: string; userId?: string }, @Request() req) {
        // Fallback to body.userId for testing if auth not set up yet
        const userId = req.user?.id || body.userId;
        return this.hydrationService.logIntake(userId, body.amountMl, body.date);
    }

    @Get('weekly')
    async getWeeklySummary(@Request() req) {
        const userId = req.user?.id; // Need to ensure this works
        if (!userId) return []; // Or throw error
        return this.hydrationService.getWeeklySummary(userId);
    }
}
