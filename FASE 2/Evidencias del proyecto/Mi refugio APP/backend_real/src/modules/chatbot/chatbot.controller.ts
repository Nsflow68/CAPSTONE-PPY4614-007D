import { Controller, Post, Body, Get, HttpCode, HttpStatus } from '@nestjs/common';
import { ChatbotService } from './chatbot.service';

@Controller('chatbot')
export class ChatbotController {
    constructor(private readonly chatbotService: ChatbotService) { }

    @Post('messages')
    @HttpCode(HttpStatus.OK)
    async sendMessage(@Body() body: { message: string }) {
        const response = await this.chatbotService.sendMessage(body.message);
        return {
            success: true,
            data: response,
        };
    }

    @Get('history')
    async getHistory() {
        const history = await this.chatbotService.getHistory();
        return {
            success: true,
            data: history,
        };
    }
}
