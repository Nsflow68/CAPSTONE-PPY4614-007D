import { Module } from '@nestjs/common';
import { HydrationController } from './hydration.controller';
import { HydrationService } from './hydration.service';

@Module({
  controllers: [HydrationController],
  providers: [HydrationService],
  exports: [HydrationService],
})
export class HydrationModule {}
