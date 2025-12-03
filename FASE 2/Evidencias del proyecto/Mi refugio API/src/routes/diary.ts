import { Router } from 'express';
import pool from '../config/db';

const router = Router();

// Obtener entradas del diario (opcionalmente filtradas por usuario)
router.get('/', async (req, res) => {
    const { userId } = req.query;

    try {
        const params: any[] = [];
        let whereClause = '';

        if (userId) {
            params.push(userId);
            whereClause = `WHERE d."userId" = $${params.length}`;
        }

        const query = `
            SELECT 
                d.id,
                d.title,
                d."content",
                d.mood,
                d.score,
                d."moodText",
                d."date",
                d."createdAt",
                d."updatedAt",
                COALESCE(d.emotions, ARRAY[]::text[]) AS emotions,
                COALESCE(d.tags, ARRAY[]::text[]) AS tags,
                d."userId",
                u.name        AS "userName",
                u.email       AS "userEmail",
                u."avatarUrl" AS "userAvatarUrl",
                u.role        AS "userRole",
                u.username    AS "userUsername",
                u.gender,
                COALESCE(u.birthdate, u."birthDate") AS birthdate,
                u."birthDate",
                FLOOR(EXTRACT(YEAR FROM AGE(COALESCE(u.birthdate, u."birthDate"))))::INT AS age
            FROM app."DiaryEntry" d
            LEFT JOIN app.users u ON u.id = d."userId"
            ${whereClause}
            ORDER BY d."date" DESC, d."createdAt" DESC;
        `;

        const result = await pool.query(query, params);

        const rows = result.rows.map(row => ({
            ...row,
            emotions: row.emotions || [],
            tags: row.tags || []
        }));

        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener entradas del diario' });
    }
});

export default router;
