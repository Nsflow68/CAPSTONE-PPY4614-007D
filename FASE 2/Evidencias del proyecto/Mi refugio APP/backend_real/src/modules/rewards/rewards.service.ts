import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserRewards } from './entities/user-rewards.entity';

@Injectable()
export class RewardsService {
    constructor(
        @InjectRepository(UserRewards)
        private rewardsRepository: Repository<UserRewards>,
    ) { }

    async getRewards(userId: string) {
        let rewards = await this.rewardsRepository.findOne({ where: { userId } });
        if (!rewards) {
            rewards = this.rewardsRepository.create({
                userId,
                points: 0,
                currentStreak: 0,
                unlockedMascots: ['pose_1'], // Default unlock
            });
            await this.rewardsRepository.save(rewards);
        }
        return rewards;
    }

    async addPoints(userId: string, amount: number) {
        const rewards = await this.getRewards(userId);
        rewards.points += amount;

        // Check for unlocks
        this.checkUnlocks(rewards);

        return this.rewardsRepository.save(rewards);
    }

    private checkUnlocks(rewards: UserRewards) {
        // Logic to unlock poses based on points
        if (rewards.points >= 100 && !rewards.unlockedMascots.includes('pose_2')) {
            rewards.unlockedMascots.push('pose_2');
        }
        if (rewards.points >= 300 && !rewards.unlockedMascots.includes('pose_3')) {
            rewards.unlockedMascots.push('pose_3');
        }
        if (rewards.points >= 500 && !rewards.unlockedMascots.includes('pose_4')) {
            rewards.unlockedMascots.push('pose_4');
        }
    }
}
