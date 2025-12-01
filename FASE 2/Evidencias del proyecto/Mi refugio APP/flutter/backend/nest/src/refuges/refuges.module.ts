import { Module } from '@nestjs/common';
import { RefugesController } from './refuges.controller';
import { RefugesService } from './refuges.service';
import { PrismaModule } from '../database/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [RefugesController],
  providers: [RefugesService],
  exports: [RefugesService],
})
export class RefugesModule {}
