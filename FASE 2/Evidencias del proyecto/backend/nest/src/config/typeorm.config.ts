import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import * as dotenv from 'dotenv';

dotenv.config();

export const typeOrmConfig: TypeOrmModuleOptions = {
    type: 'postgres',
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT || '5432', 10),
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    entities: [__dirname + '/../**/*.entity.{js,ts}'],
    synchronize: false, // CRITICAL: Do not sync to avoid dropping existing tables
    ssl: {
        rejectUnauthorized: false,
    },
    // We need to support both 'app' and 'web' schemas
    // In TypeORM, we define schema in the Entity decorator
};
