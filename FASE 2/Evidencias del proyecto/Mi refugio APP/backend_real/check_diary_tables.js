const { Client } = require('pg');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'mirefugio',
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function checkDiaryTables() {
    try {
        await client.connect();
        console.log('✅ Conectado a la base de datos mirefugio\n');

        // Check for diary-related tables
        const tables = await client.query(`
      SELECT table_schema, table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'app' 
      AND (table_name LIKE '%diary%' OR table_name LIKE '%diario%' OR table_name LIKE '%entry%' OR table_name LIKE '%entrada%')
      ORDER BY table_name
    `);

        console.log('📊 Tablas relacionadas con Diario:');
        if (tables.rows.length === 0) {
            console.log('   ⚠️  No se encontraron tablas de diario');
        } else {
            tables.rows.forEach(row => {
                console.log(`   - ${row.table_schema}.${row.table_name}`);
            });
        }

        // List all tables in app schema
        console.log('\n📋 Todas las tablas en el schema app:');
        const allTables = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'app'
      ORDER BY table_name
    `);

        if (allTables.rows.length === 0) {
            console.log('   ⚠️  No hay tablas en el schema app');
        } else {
            allTables.rows.forEach(row => {
                console.log(`   - app.${row.table_name}`);
            });
        }

        // Check columns of users table to understand the pattern
        console.log('\n🔍 Estructura de la tabla app.users (para referencia):');
        const userColumns = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_schema = 'app' AND table_name = 'users'
      ORDER BY ordinal_position
    `);

        userColumns.rows.forEach(col => {
            console.log(`   - ${col.column_name}: ${col.data_type} ${col.is_nullable === 'NO' ? '(NOT NULL)' : ''}`);
        });

    } catch (err) {
        console.error('\n❌ Error:', err.message);
    } finally {
        await client.end();
    }
}

checkDiaryTables();
