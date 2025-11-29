import pool from './config/db';

const checkTables = async () => {
    try {
        const result = await pool.query(`
            SELECT table_schema, table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'API'
            ORDER BY table_name;
        `);

        console.log('Tablas encontradas en el esquema API:');
        if (result.rows.length === 0) {
            console.log('No se encontraron tablas en el esquema API.');
        } else {
            result.rows.forEach(row => {
                console.log(`${row.table_schema}.${row.table_name}`);
            });
        }

    } catch (error) {
        console.error('Error buscando tablas:', error);
    } finally {
        await pool.end();
    }
};

checkTables();
