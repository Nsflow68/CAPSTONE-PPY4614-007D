import { Router } from 'express';
import pool from '../config/db';
import pbkdf2 from 'pbkdf2';

const router = Router();

// Helper to verify Django password
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

router.post('/login', async (req, res) => {
    const { username, password } = req.body;

    try {
        // Query Django's auth_user table
        const result = await pool.query('SELECT * FROM web.auth_user WHERE username = $1', [username]);

        if (result.rows.length === 0) {
            return res.status(401).json({ success: false, message: 'Credenciales inválidas' });
        }

        const user = result.rows[0];

        // Verify password using Django's algorithm
        const match = verifyDjangoPassword(password, user.password);

        if (!match) {
            return res.status(401).json({ success: false, message: 'Credenciales inválidas' });
        }

        // Check for admin/staff access
        if (!user.is_staff && !user.is_superuser) {
            return res.status(403).json({ success: false, message: 'Acceso denegado: Se requieren permisos de administrador' });
        }

        res.json({
            success: true,
            user: {
                id: user.id,
                username: user.username,
                full_name: `${user.first_name} ${user.last_name}`.trim(),
                role: user.is_superuser ? 'admin' : 'staff'
            }
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Error del servidor' });
    }
});

export default router;
