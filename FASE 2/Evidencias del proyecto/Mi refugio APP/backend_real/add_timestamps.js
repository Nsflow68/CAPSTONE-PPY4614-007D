const { Client } = require('pg');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'mirefugio',
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function addMissingColumns() {
    try {
        await client.connect();
        console.log('✅ Conectado a la base de datos');

        // Check createdAt
        const checkCreated = await client.query(`
      SELECT column_name FROM information_schema.columns 
      WHERE table_schema = 'app' AND table_name = 'DiaryEntry' AND column_name = 'createdAt'
    `);

        if (checkCreated.rows.length === 0) {
            console.log('➕ Agregando columna "createdAt"...');
            await client.query(`
        ALTER TABLE app."DiaryEntry" 
        ADD COLUMN "createdAt" timestamp without time zone NOT NULL DEFAULT NOW();
      `);
        } else {
            console.log('ℹ️ La columna "createdAt" ya existe.');
        }

        // Check updatedAt
        const checkUpdated = await client.query(`
      SELECT column_name FROM information_schema.columns 
      WHERE table_schema = 'app' AND table_name = 'DiaryEntry' AND column_name = 'updatedAt'
    `);

        if (checkUpdated.rows.length === 0) {
            console.log('➕ Agregando columna "updatedAt"...');
            await client.query(`
        ALTER TABLE app."DiaryEntry" 
        ADD COLUMN "updatedAt" timestamp without time zone NOT NULL DEFAULT NOW();
      `);
        } else {
            console.log('ℹ️ La columna "updatedAt" ya existe.');
        }

        console.log('✅ Columnas verificadas/agregadas.');

    } catch (err) {
        console.error('❌ Error:', err.message);
    } finally {
        await client.end();
    }
}

addMissingColumns();
