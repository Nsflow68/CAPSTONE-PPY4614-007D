import { Entity, Column, PrimaryColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity({ schema: 'app', name: 'DiaryEntry' })
export class DiaryEntry {
    @PrimaryColumn('text')
    id: string;

    @Column('text')
    title: string;

    @Column('text')
    content: string;

    @Column('text')
    mood: string;

    @Column('integer')
    score: number;

    @Column('text', { nullable: true })
    moodText: string;

    @Column('text', { array: true })
    emotions: string[];

    @Column('text', { array: true })
    tags: string[];

    @Column('timestamp without time zone')
    date: Date;

    @Column('text')
    userId: string;

    @CreateDateColumn({ type: 'timestamp without time zone' })
    createdAt: Date;

    @UpdateDateColumn({ type: 'timestamp without time zone' })
    updatedAt: Date;
}
