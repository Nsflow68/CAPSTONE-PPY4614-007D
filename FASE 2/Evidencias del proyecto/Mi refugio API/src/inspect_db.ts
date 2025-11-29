import pool from './config/db';

const inspect = async () => {
    try {
        // Try to select one row to see columns
        const result = await pool.query('SELECT * FROM nest_backend."Resource" LIMIT 1');
        console.log('Columns:', result.fields.map(f => f.name));
        console.log('Sample Row:', result.rows[0]);
    } catch (error) {
        console.error('Error inspecting table:', error);
    } finally {
        await pool.end();
    }
};

inspect();
