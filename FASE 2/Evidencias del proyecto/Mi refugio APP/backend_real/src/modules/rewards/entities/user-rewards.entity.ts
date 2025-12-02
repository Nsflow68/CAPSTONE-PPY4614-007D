import { Entity, Column, PrimaryGeneratedColumn, OneToOne, JoinColumn, UpdateDateColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('user_rewards')
export class UserRewards {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @OneToOne(() => User, { onDelete: 'CASCADE' })
    @JoinColumn()
    user: User;

    @Column()
    userId: string;

    @Column('int', { default: 0 })
    points: number;

    @Column('int', { default: 0 })
    currentStreak: number;

    @Column('simple-array', { nullable: true })
    unlockedMascots: string[]; // e.g. ['pose_1', 'pose_2']

    @UpdateDateColumn()
    updatedAt: Date;
}
