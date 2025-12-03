const { Client } = require('pg');

const config = {
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    database: 'postgres', // Try postgres first
    ssl: false, // Try false first
};

async function test(dbName, ssl) {
    console.log(`Testing DB: ${dbName}, SSL: ${ssl}`);
    const client = new Client({ ...config, database: dbName, ssl: ssl ? { rejectUnauthorized: false } : false });
    try {
        await client.connect();
        console.log('SUCCESS!');
        await client.end();
    } catch (err) {
        console.log('FAILED:', err.message);
    }
}

async function run() {
    await test('postgres', false);
    await test('postgres', true);
    await test('mirefugio', false);
    await test('mirefugio', true);
}

run();
