import pool from './config/db';

const checkDiary = async () => {
    try {
        const result = await pool.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_schema = 'app' AND table_name = 'DiaryEntry';
        `);

        console.log('Columnas de app."DiaryEntry":');
        result.rows.forEach(row => {
            console.log(`${row.column_name} (${row.data_type})`);
        });

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await pool.end();
    }
};

checkDiary();
