import { Router } from 'express';
import pool from '../config/db';

const router = Router();

// List all entries
router.get('/', async (req, res) => {
    try {
        // Confirmar existencia de la tabla antes de consultar
        const existsResult = await pool.query(`
            SELECT to_regclass('chatbot_responses') AS regclass
        `);
        const regclass = existsResult.rows[0]?.regclass;

        if (!regclass) {
            return res.json([]);
        }

        const result = await pool.query(`SELECT * FROM ${regclass} ORDER BY keyword`);
        res.json(result.rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener datos' });
    }
});

// Create entry
router.post('/', async (req, res) => {
    const { keyword, response } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO chatbot_responses (keyword, response) VALUES ($1, $2) RETURNING *',
            [keyword, response]
        );
        res.json(result.rows[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al crear registro' });
    }
});

// Update entry
router.put('/:id', async (req, res) => {
    const { id } = req.params;
    const { keyword, response } = req.body;
    try {
        const result = await pool.query(
            'UPDATE chatbot_responses SET keyword = $1, response = $2 WHERE id = $3 RETURNING *',
            [keyword, response, id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Registro no encontrado' });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al actualizar registro' });
    }
});

// Delete entry
router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('DELETE FROM chatbot_responses WHERE id = $1', [id]);
        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Registro no encontrado' });
        }
        res.json({ success: true });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al eliminar registro' });
    }
});

export default router;
