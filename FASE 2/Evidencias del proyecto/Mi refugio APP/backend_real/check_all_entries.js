const { Client } = require('pg');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'mirefugio',
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function checkAllEntries() {
    try {
        await client.connect();
        console.log('✅ Conectado a la base de datos');

        // Get ALL entries
        const entriesRes = await client.query(`SELECT id, title, "userId", "createdAt" FROM app."DiaryEntry" ORDER BY "createdAt" DESC`);
        console.log(`📊 Total entradas en la tabla: ${entriesRes.rows.length}`);

        if (entriesRes.rows.length > 0) {
            console.table(entriesRes.rows);
        } else {
            console.log('⚠️ La tabla está vacía.');
        }

    } catch (err) {
        console.error('❌ Error:', err.message);
    } finally {
        await client.end();
    }
}

checkAllEntries();
