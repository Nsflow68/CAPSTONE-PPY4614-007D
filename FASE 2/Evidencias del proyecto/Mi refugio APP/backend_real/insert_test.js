const { Client } = require('pg');
const { v4: uuidv4 } = require('uuid');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'mirefugio',
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function insertTestEntry() {
    try {
        await client.connect();
        console.log('✅ Conectado a la base de datos');

        const id = uuidv4();
        const userId = 'test-user';
        const now = new Date();

        const query = `
      INSERT INTO app."DiaryEntry" (
        "id", "title", "content", "mood", "score", "moodText", 
        "emotions", "tags", "date", "userId", "createdAt", "updatedAt"
      ) VALUES (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
      ) RETURNING *;
    `;

        const values = [
            id,
            'Test Entry',
            'Content',
            'Happy',
            8,
            'Feeling good',
            ['joy', 'excitement'],
            ['work', 'coding'],
            now,
            userId,
            now,
            now
        ];

        console.log('📝 Intentando insertar entrada...');
        const res = await client.query(query, values);
        console.log('✅ Entrada insertada exitosamente:', res.rows[0]);

    } catch (err) {
        console.error('❌ Error al insertar:', err.message);
        if (err.detail) console.error('   Detalle:', err.detail);
        if (err.hint) console.error('   Pista:', err.hint);
    } finally {
        await client.end();
    }
}

insertTestEntry();
