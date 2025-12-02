import { Controller, Get, Post, Put, Delete, Body, Param, Request, UseGuards } from '@nestjs/common';
import { DiaryService, CreateDiaryEntryDto } from './diary.service';

@Controller('diary')
export class DiaryController {
    constructor(private readonly diaryService: DiaryService) { }

    private getUserId(req: any): string | null {
        let userId = req.user?.id || req.headers['x-user-id'];

        // Fallback: Extract from Authorization header (Bearer <base64_userid>)
        if (!userId && req.headers.authorization) {
            const authHeader = req.headers.authorization;
            if (authHeader.startsWith('Bearer ')) {
                try {
                    const token = authHeader.split(' ')[1];
                    // Simple base64 decode for demo purposes
                    userId = Buffer.from(token, 'base64').toString('utf-8');
                    console.log('Decoded userId from token:', userId);
                } catch (e) {
                    console.error('Error decoding token:', e);
                }
            }
        }
        return userId;
    }

    @Get()
    async getEntries(@Request() req) {
        const userId = this.getUserId(req);
        if (!userId) return { entries: [] };

        return { entries: await this.diaryService.findAllByUser(userId) };
    }

    @Get(':id')
    async getEntry(@Param('id') id: string, @Request() req) {
        const userId = this.getUserId(req);
        if (!userId) throw new Error('Unauthorized');
        const entry = await this.diaryService.findOne(id, userId);
        return entry;
    }

    @Post()
    async createEntry(@Body() dto: CreateDiaryEntryDto, @Request() req) {
        console.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        console.log('HIT: POST /api/diary');
        console.log('Headers:', JSON.stringify(req.headers));
        console.log('Body:', JSON.stringify(dto));

        const userId = this.getUserId(req);
        console.log('Resolved UserId:', userId);

        if (!userId) {
            console.error('Unauthorized: No userId found');
            throw new Error('Unauthorized');
        }
        const entry = await this.diaryService.create(userId, dto);
        return entry;
    }

    @Put(':id')
    async updateEntry(
        @Param('id') id: string,
        @Body() dto: Partial<CreateDiaryEntryDto>,
        @Request() req,
    ) {
        const userId = this.getUserId(req);
        if (!userId) throw new Error('Unauthorized');
        const entry = await this.diaryService.update(id, userId, dto);
        return entry;
    }

    @Delete(':id')
    async deleteEntry(@Param('id') id: string, @Request() req) {
        const userId = this.getUserId(req);
        if (!userId) throw new Error('Unauthorized');
        await this.diaryService.delete(id, userId);
        return { message: 'Entry deleted successfully' };
    }
}
