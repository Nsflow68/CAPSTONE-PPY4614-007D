import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ChatController } from './chat.controller';
import { RefuService } from './refu/refu.service';
import { LlmLocalService } from './refu/llm-local.service';

@Module({
  imports: [HttpModule],
  controllers: [ChatController],
  providers: [RefuService, LlmLocalService],
  exports: [RefuService, LlmLocalService],
})
export class ChatModule {}
