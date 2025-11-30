import { Router } from 'express';
import pool from '../config/db';

const router = Router();

const COLUMN_QUERY = `
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'web'
      AND table_name = 'payments_donation'
`;

router.get('/', async (_req, res) => {
    try {
        const columnsResult = await pool.query(COLUMN_QUERY);
        const columns: string[] = columnsResult.rows.map((row) => row.column_name);

        const hasCurrency = columns.includes('currency');
        const hasMessage = columns.includes('message');
        const fields = ['id', 'name', 'email', 'created_at', 'amount'];
        if (hasCurrency) {
            fields.push('currency');
        }
        if (hasMessage) {
            fields.push('message');
        }

        const dataResult = await pool.query(`
            SELECT ${fields.join(', ')}
            FROM web.payments_donation
            ORDER BY created_at DESC NULLS LAST, id DESC
            LIMIT 200
        `);

        const totalResult = await pool.query(
            'SELECT COALESCE(SUM(amount), 0) AS total_amount FROM web.payments_donation',
        );

        const currencyRow = hasCurrency ? dataResult.rows.find((row) => row.currency) || {} : {};

        res.json({
            columns: ['id', 'created_at', 'amount', 'name', 'email']
                .concat(hasCurrency ? ['currency'] : [])
                .concat(hasMessage ? ['message'] : []),
            total_records: dataResult.rowCount,
            total_amount: Number(totalResult.rows[0]?.total_amount ?? 0),
            currency: (currencyRow as any).currency || null,
            data: dataResult.rows,
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener donaciones' });
    }
});

export default router;
