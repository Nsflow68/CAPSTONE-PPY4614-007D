import pool from './config/db';

const checkUsers = async () => {
    try {
        const schemas = ['web', 'public'];
        for (const schema of schemas) {
            const result = await pool.query(`
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_schema = $1 AND table_name = 'users';
            `, [schema]);

            console.log(`Columnas de ${schema}.users:`, result.rows.map(r => r.column_name).join(', '));
        }

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await pool.end();
    }
};

checkUsers();
