const { Client } = require('pg');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'postgres',
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function listTables() {
    try {
        await client.connect();
        console.log('Conectado a la base de datos');

        // List all schemas
        const schemas = await client.query(`SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('pg_catalog', 'information_schema')`);
        console.log('\nEsquemas disponibles:');
        schemas.rows.forEach(row => console.log('  -', row.schema_name));

        // List all tables
        const tables = await client.query(`SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY table_schema, table_name`);
        console.log('\nTablas disponibles:');
        tables.rows.forEach(row => console.log(`  - ${row.table_schema}.${row.table_name}`));

        // Try to find users table
        const usersTables = await client.query(`SELECT table_schema, table_name FROM information_schema.tables WHERE table_name LIKE '%user%' AND table_schema NOT IN ('pg_catalog', 'information_schema')`);
        console.log('\nTablas relacionadas con usuarios:');
        usersTables.rows.forEach(row => console.log(`  - ${row.table_schema}.${row.table_name}`));

    } catch (err) {
        console.error('Error:', err.message);
    } finally {
        await client.end();
    }
}

listTables();
