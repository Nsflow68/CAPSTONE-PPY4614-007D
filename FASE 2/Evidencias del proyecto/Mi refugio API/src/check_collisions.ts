import pool from './config/db';

const checkCollisions = async () => {
    try {
        const schemas = ['nest_backend', 'core', 'dw', 'mobile'];
        const result = await pool.query(`
            SELECT table_schema, table_name 
            FROM information_schema.tables 
            WHERE table_schema = ANY($1)
        `, [schemas]);

        const tables: Record<string, string[]> = {};
        result.rows.forEach(row => {
            if (!tables[row.table_name]) {
                tables[row.table_name] = [];
            }
            tables[row.table_name].push(row.table_schema);
        });

        console.log('--- Análisis de Tablas ---');
        let collisions = false;
        for (const [tableName, foundSchemas] of Object.entries(tables)) {
            if (foundSchemas.length > 1) {
                console.log(`⚠️ COLISIÓN: La tabla '${tableName}' existe en: ${foundSchemas.join(', ')}`);
                collisions = true;
            } else {
                console.log(`✅ '${tableName}' solo en ${foundSchemas[0]}`);
            }
        }

        if (!collisions) {
            console.log('✨ No se encontraron colisiones de nombres. Es seguro fusionar.');
        }

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await pool.end();
    }
};

checkCollisions();
