import { Body, Controller, Get, HttpException, HttpStatus, Post } from '@nestjs/common';
import { OllamaService } from './ollama.service';

@Controller('chatbot')
export class OllamaController {
  constructor(private readonly ollamaService: OllamaService) {}

  @Get('health')
  async health() {
    const status = await this.ollamaService.checkHealth();
    return { data: status };
  }

  @Post('message')
  async generate(@Body('message') message: string) {
    if (!message || message.trim() === '') {
      throw new HttpException('Message is required', HttpStatus.BAD_REQUEST);
    }

    const result = await this.ollamaService.generate({ prompt: message });
    return {
      data: {
        text: result.text,
        latencyMs: result.latencyMs,
        model: result.model,
      },
    };
  }
}
