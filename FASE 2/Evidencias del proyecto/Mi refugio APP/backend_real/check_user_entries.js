const { Client } = require('pg');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'mirefugio',
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function checkRealUserEntries() {
    try {
        await client.connect();
        console.log('✅ Conectado a la base de datos');

        // Check for the specific user
        const email = 'is.veloz@duocuc.cl';

        // First get the user ID
        const userRes = await client.query(`SELECT id, email, name FROM app.users WHERE email = $1`, [email]);

        if (userRes.rows.length === 0) {
            console.log('❌ Usuario no encontrado:', email);
            return;
        }

        const user = userRes.rows[0];
        console.log('👤 Usuario encontrado:', user);

        // Now get entries for this user
        const entriesRes = await client.query(`SELECT * FROM app."DiaryEntry" WHERE "userId" = $1`, [user.id]);
        console.log(`📊 Entradas encontradas: ${entriesRes.rows.length}`);

        if (entriesRes.rows.length > 0) {
            console.log('📝 Primera entrada (Raw):');
            console.log(JSON.stringify(entriesRes.rows[0], null, 2));
        }

    } catch (err) {
        console.error('❌ Error:', err.message);
    } finally {
        await client.end();
    }
}

checkRealUserEntries();
