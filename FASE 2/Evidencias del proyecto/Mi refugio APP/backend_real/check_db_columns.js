const { Client } = require('pg');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '.env') });

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    database: 'mirefugio',
    ssl: { rejectUnauthorized: false },
});

async function checkIsaias() {
    try {
        await client.connect();
        const res = await client.query(`
      SELECT id, email FROM app.users WHERE email = 'is.veloz@duocuc.cl';
    `);
        console.log('Found user:', res.rows);
    } catch (err) {
        console.error('Error:', err);
    } finally {
        await client.end();
    }
}

checkIsaias();
