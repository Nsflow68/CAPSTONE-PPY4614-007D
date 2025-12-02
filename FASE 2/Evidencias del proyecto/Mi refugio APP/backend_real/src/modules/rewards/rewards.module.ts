import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RewardsController } from './rewards.controller';
import { RewardsService } from './rewards.service';
import { UserRewards } from './entities/user-rewards.entity';

@Module({
    imports: [TypeOrmModule.forFeature([UserRewards])],
    controllers: [RewardsController],
    providers: [RewardsService],
    exports: [RewardsService], // Export service so other modules can use it (e.g. to add points)
})
export class RewardsModule { }
