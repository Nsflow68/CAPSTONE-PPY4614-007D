const { Client } = require('pg');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'mirefugio',
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function checkDiaryEntryStructure() {
    try {
        await client.connect();
        console.log('✅ Conectado a la base de datos\n');

        // Get DiaryEntry table structure
        console.log('📋 Estructura de la tabla app.DiaryEntry:');
        const columns = await client.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_schema = 'app' AND table_name = 'DiaryEntry'
      ORDER BY ordinal_position
    `);

        columns.rows.forEach(col => {
            const nullable = col.is_nullable === 'NO' ? '(NOT NULL)' : '';
            const defaultVal = col.column_default ? `DEFAULT ${col.column_default}` : '';
            console.log(`   - ${col.column_name}: ${col.data_type} ${nullable} ${defaultVal}`);
        });

        // Check if there are any entries
        console.log('\n📊 Conteo de entradas:');
        const count = await client.query('SELECT COUNT(*) FROM app."DiaryEntry"');
        console.log(`   Total: ${count.rows[0].count} entradas`);

        // Show sample data if exists
        if (parseInt(count.rows[0].count) > 0) {
            console.log('\n📝 Muestra de datos (primeras 3 entradas):');
            const sample = await client.query('SELECT * FROM app."DiaryEntry" LIMIT 3');
            sample.rows.forEach((row, index) => {
                console.log(`\n   Entrada ${index + 1}:`);
                Object.keys(row).forEach(key => {
                    console.log(`      ${key}: ${row[key]}`);
                });
            });
        }

    } catch (err) {
        console.error('\n❌ Error:', err.message);
    } finally {
        await client.end();
    }
}

checkDiaryEntryStructure();
