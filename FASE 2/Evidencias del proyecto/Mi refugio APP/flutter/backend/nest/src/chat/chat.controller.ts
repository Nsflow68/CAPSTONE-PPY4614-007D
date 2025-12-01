import { Body, Controller, Get, Post } from '@nestjs/common';
import { RefuService } from './refu/refu.service';
import { SendMessageDto } from './dto/send-message.dto';
import { LlmHealth } from './refu/llm-local.service';

@Controller('chat')
export class ChatController {
  constructor(private readonly refuService: RefuService) {}

  @Get('health')
  health(): Promise<LlmHealth> {
    return this.refuService.health();
  }

  @Post('refu')
  sendMessageToRefu(@Body() dto: SendMessageDto) {
    return this.refuService.sendMessage(dto);
  }

  // Alias para compatibilidad con el frontend existente
  @Post('message')
  sendMessage(@Body() dto: SendMessageDto) {
    return this.refuService.sendMessage(dto);
  }
}
