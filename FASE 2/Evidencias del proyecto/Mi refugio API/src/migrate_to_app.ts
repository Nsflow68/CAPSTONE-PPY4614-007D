import pool from './config/db';

const migrateToApp = async () => {
    try {
        console.log('Iniciando migración al esquema "app"...');

        // 1. Crear esquema app
        await pool.query('CREATE SCHEMA IF NOT EXISTS app');
        console.log('Esquema "app" creado.');

        // 2. Mover tablas de nest_backend
        const nestTables = ['User', 'Resource', 'DiaryEntry', 'HydrationLog'];
        for (const table of nestTables) {
            try {
                await pool.query(`ALTER TABLE nest_backend."${table}" SET SCHEMA app`);
                console.log(`Tabla nest_backend."${table}" movida a app.`);
            } catch (e) {
                console.log(`Nota: No se pudo mover nest_backend."${table}" (quizás no existe).`);
            }
        }

        // 3. Mover tablas de dw
        const dwTables = ['dim_date', 'dim_user', 'fact_donation', 'fact_emotion', 'fact_meal'];
        for (const table of dwTables) {
            try {
                await pool.query(`ALTER TABLE dw.${table} SET SCHEMA app`);
                console.log(`Tabla dw.${table} movida a app.`);
            } catch (e) {
                console.log(`Nota: No se pudo mover dw.${table} (quizás no existe).`);
            }
        }

        // 4. Mover tablas de API
        const apiTables = ['users', 'chatbot_responses'];
        for (const table of apiTables) {
            try {
                await pool.query(`ALTER TABLE "API".${table} SET SCHEMA app`);
                console.log(`Tabla API.${table} movida a app.`);
            } catch (e) {
                console.log(`Nota: No se pudo mover API.${table} (quizás no existe).`);
            }
        }

        // 5. Eliminar esquemas antiguos (si están vacíos)
        const schemas = ['nest_backend', 'dw', 'API', 'core', 'mobile'];
        for (const schema of schemas) {
            try {
                await pool.query(`DROP SCHEMA IF EXISTS "${schema}" CASCADE`);
                console.log(`Esquema "${schema}" eliminado.`);
            } catch (e) {
                console.error(`Error eliminando esquema "${schema}":`, e);
            }
        }

    } catch (error) {
        console.error('Error crítico en la migración:', error);
    } finally {
        await pool.end();
    }
};

migrateToApp();
