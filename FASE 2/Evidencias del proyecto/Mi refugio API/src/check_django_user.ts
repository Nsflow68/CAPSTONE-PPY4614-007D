import pool from './config/db';

const checkDjangoUser = async () => {
    try {
        // Check if table exists
        const tableRes = await pool.query(`
            SELECT table_schema, table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'web' AND table_name = 'auth_user'
        `);

        if (tableRes.rows.length === 0) {
            console.log('❌ La tabla web.auth_user NO existe.');
            return;
        }
        console.log('✅ La tabla web.auth_user existe.');

        // Check columns
        const result = await pool.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_schema = 'web' AND table_name = 'auth_user'
        `);

        console.log('Columnas de web.auth_user:');
        result.rows.forEach(row => {
            console.log(`${row.column_name} (${row.data_type})`);
        });

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await pool.end();
    }
};

checkDjangoUser();
