import pool from './config/db';

const checkData = async () => {
    try {
        const tables = ['DiaryEntry', 'HydrationLog', 'fact_donation', 'fact_emotion', 'fact_meal'];

        for (const table of tables) {
            try {
                const res = await pool.query(`SELECT COUNT(*) FROM app."${table}"`);
                console.log(`Filas en app."${table}": ${res.rows[0].count}`);
            } catch (e) {
                console.log(`Tabla app."${table}" no encontrada o error.`);
            }
        }

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await pool.end();
    }
};

checkData();
