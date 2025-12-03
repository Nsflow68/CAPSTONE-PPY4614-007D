import { Router } from 'express';
import pool from '../config/db';

const router = Router();
const TARGET_SCHEMA = 'app';

/**
 * Genera un respaldo liviano del esquema "app" (estructura y datos) y lo devuelve como JSON descargable.
 */
router.get('/backup/app-schema', async (_req, res) => {
    try {
        const tablesResult = await pool.query(
            `
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = $1
              AND table_type = 'BASE TABLE'
            ORDER BY table_name
            `,
            [TARGET_SCHEMA]
        );
        const tables = tablesResult.rows
            .map((row) => row.table_name as string)
            .filter((name) => /^[a-zA-Z0-9_]+$/.test(name)); // seguridad básica ante identificadores raros

        const backup: Record<string, any> = {
            schema: TARGET_SCHEMA,
            generated_at: new Date().toISOString(),
            columns: {},
            tables: {},
        };

        for (const table of tables) {
            const columns = await pool.query(
                `
                SELECT column_name, data_type, is_nullable, column_default, ordinal_position
                FROM information_schema.columns
                WHERE table_schema = $1
                  AND table_name = $2
                ORDER BY ordinal_position
                `,
                [TARGET_SCHEMA, table]
            );
            backup.columns[table] = columns.rows;

            // Nota: el volumen de datos depende del tamaño de la tabla. Para entornos grandes, migrar a streaming/CSV.
            const rows = await pool.query(`SELECT * FROM ${TARGET_SCHEMA}."${table}"`);
            backup.tables[table] = rows.rows;
        }

        const filename = `app_schema_backup_${new Date().toISOString().replace(/[:.]/g, '-')}.json`;
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        res.status(200).send(JSON.stringify(backup, null, 2));
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al generar respaldo del esquema app' });
    }
});

export default router;
