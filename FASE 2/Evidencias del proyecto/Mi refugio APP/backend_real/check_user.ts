
import { DataSource } from 'typeorm';
import { User } from './src/modules/users/entities/user.entity';
import * as dotenv from 'dotenv';
import * as pbkdf2 from 'pbkdf2';

dotenv.config();

const AppDataSource = new DataSource({
    type: 'postgres',
    host: process.env.DB_HOST || 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    username: process.env.DB_USER || 'mirefugio_owner',
    password: process.env.DB_PASSWORD || 'Mirefugio2025!',
    database: process.env.DB_NAME || 'mirefugio',
    entities: [User],
    ssl: { rejectUnauthorized: false },
});

function hashPassword(password: string): string {
    const salt = 'mysalt';
    const iterations = 10000;
    const derivedKey = pbkdf2.pbkdf2Sync(password, salt, iterations, 32, 'sha256');
    const hash = derivedKey.toString('base64');
    return `pbkdf2_sha256$${iterations}$${salt}$${hash}`;
}

async function checkUser() {
    try {
        await AppDataSource.initialize();
        console.log('Connected to DB');

        const email = 'is.veloz@duocuc.cl';
        const rawUser = await AppDataSource.query(`SELECT * FROM app.users WHERE email = '${email}'`);

        if (rawUser && rawUser.length > 0) {
            console.log('User ALREADY EXISTS:', rawUser[0]);
        } else {
            console.log('User NOT found. Creating...');
            const passwordHash = hashPassword('isveloz');

            // Insert user
            const { v4: uuidv4 } = require('uuid');
            const id = uuidv4();
            await AppDataSource.query(`
                INSERT INTO app.users (id, email, password, name, role, "createdAt", "updatedAt")
                VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
            `, [id, email, passwordHash, 'Ismael Veloz', 'user']);

            console.log('User CREATED successfully.');
        }

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await AppDataSource.destroy();
    }
}

checkUser();
