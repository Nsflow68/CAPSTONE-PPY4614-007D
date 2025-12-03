const { Client } = require('pg');

const client = new Client({
    host: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
    port: 5432,
    database: 'mirefugio',  // Changed from 'postgres' to 'mirefugio'
    user: 'mirefugio_owner',
    password: 'Mirefugio2025!',
    ssl: { rejectUnauthorized: false }
});

async function updateUserName() {
    try {
        await client.connect();
        console.log('Conectado a la base de datos mirefugio');

        const result = await client.query(
            `UPDATE app.users SET name = $1 WHERE email = $2 RETURNING *`,
            ['Isaias Veloz', 'is.veloz@duocuc.cl']
        );

        if (result.rowCount > 0) {
            console.log('\n✅ Usuario actualizado exitosamente:');
            console.log('   Nombre:', result.rows[0].name);
            console.log('   Email:', result.rows[0].email);
        } else {
            console.log('\n⚠️  No se encontró ningún usuario con ese email');
        }

    } catch (err) {
        console.error('\n❌ Error:', err.message);
    } finally {
        await client.end();
    }
}

updateUserName();
