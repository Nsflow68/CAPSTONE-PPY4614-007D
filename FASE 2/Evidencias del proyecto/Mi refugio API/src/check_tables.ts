import pool from './config/db';

const checkTables = async () => {
    try {
        const result = await pool.query(`
            SELECT table_schema, table_name 
            FROM information_schema.tables 
            WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
            ORDER BY table_schema, table_name;
        `);
        
        console.log('Tablas encontradas en la base de datos:');
        result.rows.forEach(row => {
            console.log(`${row.table_schema}.${row.table_name}`);
        });

    } catch (error) {
        console.error('Error buscando tablas:', error);
    } finally {
        await pool.end();
    }
};

checkTables();
