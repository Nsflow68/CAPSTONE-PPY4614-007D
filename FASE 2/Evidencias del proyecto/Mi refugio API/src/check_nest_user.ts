import pool from './config/db';

const checkNestUser = async () => {
    try {
        const result = await pool.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_schema = 'nest_backend' AND table_name = 'User';
        `);

        console.log('Columnas de nest_backend."User":');
        result.rows.forEach(row => {
            console.log(`${row.column_name} (${row.data_type})`);
        });

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await pool.end();
    }
};

checkNestUser();
