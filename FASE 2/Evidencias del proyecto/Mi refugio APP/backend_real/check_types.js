const { Client } = require('pg');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'mirefugio',
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function checkColumnTypes() {
    try {
        await client.connect();

        const query = `
      SELECT column_name, data_type, udt_name
      FROM information_schema.columns
      WHERE table_schema = 'app' AND table_name = 'DiaryEntry'
      AND column_name IN ('emotions', 'tags');
    `;

        const res = await client.query(query);
        console.table(res.rows);

    } catch (err) {
        console.error(err);
    } finally {
        await client.end();
    }
}

checkColumnTypes();
