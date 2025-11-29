import { Router } from 'express';
import pool from '../config/db';

const router = Router();

// List all resources
router.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM app."Resource" ORDER BY name');
        res.json(result.rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener recursos' });
    }
});

export default router;
