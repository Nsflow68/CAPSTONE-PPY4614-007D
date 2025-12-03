const { Client } = require('pg');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'mirefugio',
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function addDateColumn() {
    try {
        await client.connect();
        console.log('✅ Conectado a la base de datos');

        // Check if column exists
        const check = await client.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_schema = 'app' 
      AND table_name = 'DiaryEntry' 
      AND column_name = 'date'
    `);

        if (check.rows.length > 0) {
            console.log('ℹ️ La columna "date" ya existe.');
        } else {
            console.log('➕ Agregando columna "date"...');
            await client.query(`
        ALTER TABLE app."DiaryEntry" 
        ADD COLUMN "date" timestamp without time zone NOT NULL DEFAULT NOW();
      `);
            console.log('✅ Columna "date" agregada exitosamente.');
        }

    } catch (err) {
        console.error('❌ Error:', err.message);
    } finally {
        await client.end();
    }
}

addDateColumn();
