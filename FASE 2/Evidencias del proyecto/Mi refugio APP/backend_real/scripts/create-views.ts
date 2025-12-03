import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Migration to add new user fields
const migration = `
-- Add new user fields if they don't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='app' AND table_name='users' AND column_name='rut') THEN
        ALTER TABLE app.users ADD COLUMN rut VARCHAR;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='app' AND table_name='users' AND column_name='birthDate') THEN
        ALTER TABLE app.users ADD COLUMN "birthDate" TIMESTAMP;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='app' AND table_name='users' AND column_name='gender') THEN
        ALTER TABLE app.users ADD COLUMN gender VARCHAR;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='app' AND table_name='users' AND column_name='registrationNumber') THEN
        ALTER TABLE app.users ADD COLUMN "registrationNumber" VARCHAR;
    END IF;
END $$;

-- Create unique index on rut if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='app' AND tablename='users' AND indexname='IDX_users_rut') THEN
        CREATE UNIQUE INDEX "IDX_users_rut" ON app.users (rut);
    END IF;
END $$;
`;

// Create views script
const createViews = `
-- Vista para hacer los datos más legibles en DBeaver
CREATE OR REPLACE VIEW app.users_readable AS
SELECT 
    SUBSTRING(id, 1, 8) as user_id_short,
    id as user_id_full,
    email,
    username,
    name,
    rut,
    TO_CHAR("birthDate", 'DD/MM/YYYY') as fecha_nacimiento,
    gender as genero,
    "registrationNumber" as numero_registro,
    role as rol,
    TO_CHAR("createdAt", 'DD/MM/YYYY HH24:MI') as fecha_creacion,
    TO_CHAR("updatedAt", 'DD/MM/YYYY HH24:MI') as fecha_actualizacion
FROM app.users
ORDER BY "createdAt" DESC;
`;

async function run() {
    const dataSource = new DataSource({
        type: 'postgres',
        host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
        port: 5432,
        username: 'mirefugio_owner',
        password: 'Mirefugio2025!',
        database: 'mirefugio',
        ssl: {
            rejectUnauthorized: false
        }
    });

    try {
        await dataSource.initialize();
        console.log('✓ Conectado a la base de datos AWS RDS');

        // Run migration first
        console.log('Ejecutando migración...');
        await dataSource.query(migration);
        console.log('✓ Migración completada');

        // Then create views
        console.log('Creando vistas...');
        await dataSource.query(createViews);
        console.log('✓ Vistas creadas exitosamente');
        console.log('');
        console.log('consultar en DBeaver:');
        console.log('   SELECT * FROM app.users_readable;');
        console.log('');
        console.log('Los IDs aparecerán acortados y las fechas formateadas.');

        await dataSource.destroy();
    } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
    }
}

run();
