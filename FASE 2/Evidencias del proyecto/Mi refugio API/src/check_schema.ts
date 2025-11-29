import pool from './config/db';

const checkSchema = async () => {
    try {
        // Check search_path
        const pathRes = await pool.query('SHOW search_path');
        console.log('Search Path:', pathRes.rows[0].search_path);

        // Check columns of web.chatbot_responses
        const result = await pool.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_schema = 'web' AND table_name = 'chatbot_responses';
        `);

        console.log('Columnas de web.chatbot_responses:');
        result.rows.forEach(row => {
            console.log(`${row.column_name} (${row.data_type})`);
        });

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await pool.end();
    }
};

checkSchema();
