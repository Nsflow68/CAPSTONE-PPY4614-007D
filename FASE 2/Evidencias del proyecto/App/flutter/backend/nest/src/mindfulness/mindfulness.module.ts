import { Module } from '@nestjs/common';
import { MindfulnessService } from './mindfulness.service';
import { MindfulnessController } from './mindfulness.controller';

@Module({
  controllers: [MindfulnessController],
  providers: [MindfulnessService],
})
export class MindfulnessModule {}
