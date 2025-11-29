import pool from './config/db';

const alterTables = async () => {
    try {
        console.log('Iniciando modificación de tablas...');

        // 1. Modificar DiaryEntry
        await pool.query(`
            ALTER TABLE app."DiaryEntry" 
            DROP COLUMN IF EXISTS "userId",
            ADD COLUMN "userId" INTEGER,
            ADD CONSTRAINT fk_diary_user FOREIGN KEY ("userId") REFERENCES web.auth_user(id);
        `);
        console.log('✅ app."DiaryEntry" actualizada.');

        // 2. Modificar HydrationLog
        await pool.query(`
            ALTER TABLE app."HydrationLog" 
            DROP COLUMN IF EXISTS "userId",
            ADD COLUMN "userId" INTEGER,
            ADD CONSTRAINT fk_hydration_user FOREIGN KEY ("userId") REFERENCES web.auth_user(id);
        `);
        console.log('✅ app."HydrationLog" actualizada.');

        // 3. Eliminar tablas de usuarios redundantes en app
        await pool.query('DROP TABLE IF EXISTS app.users CASCADE');
        await pool.query('DROP TABLE IF EXISTS app."User" CASCADE');
        console.log('✅ Tablas redundantes (app.users, app.User) eliminadas.');

    } catch (error) {
        console.error('Error modificando tablas:', error);
    } finally {
        await pool.end();
    }
};

alterTables();
