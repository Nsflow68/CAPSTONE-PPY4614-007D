import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('nutrition_logs')
export class NutritionLog {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ManyToOne(() => User, { onDelete: 'CASCADE' })
    user: User;

    @Column()
    userId: string;

    @Column({ type: 'date' })
    date: string;

    @Column()
    mealType: string; // Breakfast, Lunch, Dinner, Snack

    @Column('int')
    calories: number;

    @Column('int')
    protein: number;

    @Column('int')
    carbs: number;

    @Column('int')
    fat: number;

    @Column('simple-array', { nullable: true })
    foodItems: string[];

    @CreateDateColumn()
    createdAt: Date;
}
