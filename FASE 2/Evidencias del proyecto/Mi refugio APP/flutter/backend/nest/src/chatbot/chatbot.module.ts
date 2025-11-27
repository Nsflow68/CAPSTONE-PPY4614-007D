import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ChatbotService } from './chatbot.service';
import { ChatbotController } from './chatbot.controller';
import { OllamaService } from './ollama.service';

@Module({
  imports: [HttpModule],
  controllers: [ChatbotController],
  providers: [ChatbotService, OllamaService],
})
export class ChatbotModule {}
