const { Client } = require('pg');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'mirefugio',
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function checkColumns() {
    try {
        await client.connect();
        const res = await client.query(`
      SELECT column_name
      FROM information_schema.columns
      WHERE table_schema = 'app' AND table_name = 'users'
      AND column_name IN ('createdAt', 'updatedAt');
    `);
        console.log('Found columns:', res.rows.map(r => r.column_name));
    } catch (err) {
        console.error(err);
    } finally {
        await client.end();
    }
}

checkColumns();
