import pool from './config/db';
import pbkdf2 from 'pbkdf2';

const verifyDjangoPassword = (password: string, djangoHash: string): boolean => {
    const parts = djangoHash.split('$');
    if (parts.length !== 4) return false;

    const [algorithm, iterationsStr, salt, hash] = parts;
    const iterations = parseInt(iterationsStr, 10);

    if (algorithm !== 'pbkdf2_sha256') return false;

    const derivedKey = pbkdf2.pbkdf2Sync(password, salt, iterations, 32, 'sha256');
    const derivedKeyBase64 = derivedKey.toString('base64');

    return derivedKeyBase64 === hash;
};

const testLogin = async () => {
    try {
        console.log('Buscando usuarios en web.auth_user...');
        const result = await pool.query('SELECT * FROM web.auth_user LIMIT 1');

        if (result.rows.length === 0) {
            console.log('⚠️ No hay usuarios en web.auth_user para probar.');
            return;
        }

        const user = result.rows[0];
        console.log(`Usuario encontrado: ${user.username}`);
        console.log(`Hash: ${user.password.substring(0, 20)}...`);
        console.log(`Es Staff: ${user.is_staff}`);

        // Nota: No puedo probar la contraseña real porque no la sé, 
        // pero puedo verificar que el algoritmo de hash funciona si tuviera la password.
        // Por ahora, solo confirmo que puedo leer el usuario y su hash.

        console.log('✅ Lectura de usuario exitosa.');

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await pool.end();
    }
};

testLogin();
