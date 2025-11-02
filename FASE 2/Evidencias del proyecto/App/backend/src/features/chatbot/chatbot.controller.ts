import { Body, Controller, Get, Post } from '@nestjs/common';
import { ChatbotService } from './chatbot.service';

@Controller('chatbot')
export class ChatbotController {
  constructor(private readonly chatbotService: ChatbotService) {}

  @Get('history')
  history() {
    return { data: this.chatbotService.getHistory() };
  }

  @Post('messages')
  send(@Body('message') message: string) {
    return { data: this.chatbotService.sendMessage(message ?? '') };
  }
}
