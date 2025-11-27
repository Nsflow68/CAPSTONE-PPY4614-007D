import { Body, Controller, Get, Post } from '@nestjs/common';
import { ChatbotService } from './chatbot.service';
import { SendMessageDto } from './dto/send-message.dto';
import { OllamaHealth } from './ollama.service';

@Controller('chatbot')
export class ChatbotController {
  constructor(private readonly chatbotService: ChatbotService) {}

  @Get('health')
  health(): Promise<OllamaHealth> {
    return this.chatbotService.health();
  }

  @Post('message')
  sendMessage(@Body() dto: SendMessageDto) {
    return this.chatbotService.sendMessage(dto);
  }
}
