import pool from './config/db';
import pbkdf2 from 'pbkdf2';
import crypto from 'crypto';

// 1. Logic from src/routes/users.ts (Creation)
const hashPasswordForDjango = (password: string): string => {
    const salt = crypto.randomBytes(12).toString('base64');
    const iterations = 100000;
    const keylen = 32;
    const digest = 'sha256';

    const derivedKey = pbkdf2.pbkdf2Sync(password, salt, iterations, keylen, digest);
    const hash = derivedKey.toString('base64');

    return `pbkdf2_sha256$${iterations}$${salt}$${hash}`;
};

// 2. Logic from src/routes/auth.ts (Verification)
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

const testUserFlow = async () => {
    const testUser = {
        username: 'test_api_user',
        password: 'securePassword123!',
        email: 'test@example.com',
        first_name: 'Test',
        last_name: 'User'
    };

    try {
        console.log('1. Creando usuario de prueba...');
        const passwordHash = hashPasswordForDjango(testUser.password);

        // Clean up previous run if exists
        await pool.query('DELETE FROM web.auth_user WHERE username = $1', [testUser.username]);

        // Insert
        await pool.query(
            `INSERT INTO web.auth_user 
            (username, password, first_name, last_name, email, is_superuser, is_staff, is_active, date_joined) 
            VALUES ($1, $2, $3, $4, $5, false, false, true, NOW())`,
            [testUser.username, passwordHash, testUser.first_name, testUser.last_name, testUser.email]
        );
        console.log('✅ Usuario creado en web.auth_user.');

        console.log('2. Intentando "Login" (Verificación de hash)...');
        // Fetch user
        const result = await pool.query('SELECT * FROM web.auth_user WHERE username = $1', [testUser.username]);
        const user = result.rows[0];

        // Verify
        const isValid = verifyDjangoPassword(testUser.password, user.password);

        if (isValid) {
            console.log('✅ ¡ÉXITO! La contraseña creada es válida para el sistema de login.');
        } else {
            console.error('❌ FALLO: La contraseña no coincide.');
        }

        // Cleanup
        await pool.query('DELETE FROM web.auth_user WHERE username = $1', [testUser.username]);
        console.log('3. Limpieza realizada.');

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await pool.end();
    }
};

testUserFlow();
