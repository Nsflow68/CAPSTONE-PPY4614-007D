import { Entity, Column, PrimaryColumn, BeforeInsert } from 'typeorm';

@Entity({ schema: 'app', name: 'users' })
export class User {
    @PrimaryColumn('text')  // Changed from PrimaryGeneratedColumn since DB uses text UUID
    id: string;

    @Column({ unique: true })
    email: string;

    @Column({ unique: true, nullable: true }) // nullable true just in case, but likely required
    username: string;

    @Column({ nullable: true })
    name: string;

    @Column({ select: false }) // Do not return password by default
    password: string;

    @Column({ default: 'user' })
    role: string;

    @Column({ unique: true })
    rut: string;

    @Column({ name: 'birthdate', nullable: true })
    birthDate: Date;

    @Column({ nullable: true })
    gender: string;

    @Column({ type: 'timestamp', nullable: true })
    createdAt: Date;

    @Column({ type: 'timestamp', nullable: true })
    updatedAt: Date;

    @BeforeInsert()
    setTimestamps() {
        const now = new Date();
        this.createdAt = now;
        this.updatedAt = now;
    }
}
