import pool from './config/db';
import bcrypt from 'bcrypt';

const fixAdmin = async () => {
    try {
        const password = 'admin123';
        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(password, salt);

        await pool.query('UPDATE users SET password_hash = $1 WHERE username = $2', [hash, 'admin']);
        console.log('Password de admin actualizado correctamente.');
    } catch (error) {
        console.error('Error actualizando admin:', error);
    } finally {
        await pool.end();
    }
};

fixAdmin();
