import { Router } from 'express';
import pool from '../config/db';
import pbkdf2 from 'pbkdf2';
import crypto from 'crypto';

const router = Router();

// Helper to hash password for Django (PBKDF2)
const hashPasswordForDjango = (password: string): string => {
    const salt = crypto.randomBytes(12).toString('base64');
    const iterations = 100000;
    const keylen = 32;
    const digest = 'sha256';

    const derivedKey = pbkdf2.pbkdf2Sync(password, salt, iterations, keylen, digest);
    const hash = derivedKey.toString('base64');

    return `pbkdf2_sha256$${iterations}$${salt}$${hash}`;
};

// List all users
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM web.auth_user ORDER BY username');
        const users = result.rows.map(row => ({
            id: row.id,
            username: row.username,
            email: row.email,
            full_name: `${row.first_name} ${row.last_name}`.trim(),
            role: row.is_superuser ? 'admin' : (row.is_staff ? 'staff' : 'user'),
            status: row.is_active ? 'Activo' : 'Inactivo',
            // Fields for compatibility with Desk UI if needed
            gender: 'No especificado',
            age: null
        }));
        res.json(users);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener usuarios' });
    }
});

// Create user
router.post('/', async (req, res) => {
    const { username, password, full_name, role, email } = req.body;

    // Split full_name into first and last name for Django
    const nameParts = (full_name || '').split(' ');
    const firstName = nameParts[0] || '';
    const lastName = nameParts.slice(1).join(' ') || '';

    // Determine flags based on role
    const isSuperuser = role === 'admin';
    const isStaff = role === 'admin' || role === 'staff';

    try {
        const passwordHash = hashPasswordForDjango(password);

        const result = await pool.query(
            `INSERT INTO web.auth_user 
            (username, password, first_name, last_name, email, is_superuser, is_staff, is_active, date_joined) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, true, NOW()) 
            RETURNING *`,
            [username, passwordHash, firstName, lastName, email || username, isSuperuser, isStaff]
        );

        const row = result.rows[0];
        res.json({
            id: row.id,
            username: row.username,
            full_name: `${row.first_name} ${row.last_name}`.trim(),
            role: row.is_superuser ? 'admin' : (row.is_staff ? 'staff' : 'user'),
            status: 'Activo'
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al crear usuario' });
    }
});

// Update user
router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { username, full_name, role, password, email, status } = req.body;

    try {
        let query = 'UPDATE web.auth_user SET id = id'; // Dummy start
        const values = [];
        let idx = 1;

        if (username) {
            query += `, username = $${idx++}`;
            values.push(username);
        }
        if (email) {
            query += `, email = $${idx++}`;
            values.push(email);
        }
        if (full_name) {
            const nameParts = full_name.split(' ');
            const firstName = nameParts[0] || '';
            const lastName = nameParts.slice(1).join(' ') || '';

            query += `, first_name = $${idx++}, last_name = $${idx++}`;
            values.push(firstName);
            values.push(lastName);
        }
        if (role) {
            const isSuperuser = role === 'admin';
            const isStaff = role === 'admin' || role === 'staff';
            query += `, is_superuser = $${idx++}, is_staff = $${idx++}`;
            values.push(isSuperuser);
            values.push(isStaff);
        }
        if (status) {
            const isActive = status === 'Activo';
            query += `, is_active = $${idx++}`;
            values.push(isActive);
        }
        if (password) {
            const hash = hashPasswordForDjango(password);
            query += `, password = $${idx++}`;
            values.push(hash);
        }

        query += ` WHERE id = $${idx} RETURNING *`;
        values.push(id);

        const result = await pool.query(query, values);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        const row = result.rows[0];
        res.json({
            id: row.id,
            username: row.username,
            full_name: `${row.first_name} ${row.last_name}`.trim(),
            role: row.is_superuser ? 'admin' : (row.is_staff ? 'staff' : 'user'),
            status: row.is_active ? 'Activo' : 'Inactivo'
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al actualizar usuario' });
    }
});

// Delete user
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('DELETE FROM web.auth_user WHERE id = $1', [id]);
        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        res.json({ success: true });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al eliminar usuario' });
    }
});

export default router;
