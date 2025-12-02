import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HydrationController } from './hydration.controller';
import { HydrationService } from './hydration.service';
import { HydrationLog } from './entities/hydration.entity';

@Module({
    imports: [TypeOrmModule.forFeature([HydrationLog])],
    controllers: [HydrationController],
    providers: [HydrationService],
})
export class HydrationModule { }
