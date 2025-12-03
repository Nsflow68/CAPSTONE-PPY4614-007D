const { Client } = require('pg');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'mirefugio',
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function checkEntries() {
    try {
        await client.connect();
        console.log('✅ Conectado a la base de datos');

        const res = await client.query(`SELECT * FROM app."DiaryEntry"`);
        console.log(`📊 Total entradas: ${res.rows.length}`);
        console.table(res.rows.map(r => ({ id: r.id, userId: r.userId, title: r.title })));

    } catch (err) {
        console.error('❌ Error:', err.message);
    } finally {
        await client.end();
    }
}

checkEntries();
