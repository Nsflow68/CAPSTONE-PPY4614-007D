import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('hydration_logs')
export class HydrationLog {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ManyToOne(() => User, { onDelete: 'CASCADE' })
    user: User;

    @Column()
    userId: string;

    @Column({ type: 'date' })
    date: string;

    @Column('int')
    amountMl: number;

    @CreateDateColumn()
    createdAt: Date;
}
