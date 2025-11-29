import pool from './config/db';

const checkAppTables = async () => {
    try {
        const result = await pool.query(`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'app'
            ORDER BY table_name;
        `);

        console.log('Tablas en el esquema "app":');
        if (result.rows.length === 0) {
            console.log('No se encontraron tablas.');
        } else {
            result.rows.forEach(row => {
                console.log(`- ${row.table_name}`);
            });
        }

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await pool.end();
    }
};

checkAppTables();
