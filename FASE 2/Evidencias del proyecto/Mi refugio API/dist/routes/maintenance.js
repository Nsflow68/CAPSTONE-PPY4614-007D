"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const db_1 = __importDefault(require("../config/db"));
const router = (0, express_1.Router)();
const TARGET_SCHEMA = 'app';
/**
 * Genera un respaldo liviano del esquema "app" (estructura y datos) y lo devuelve como JSON descargable.
 */
router.get('/backup/app-schema', (_req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const tablesResult = yield db_1.default.query(`
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = $1
              AND table_type = 'BASE TABLE'
            ORDER BY table_name
            `, [TARGET_SCHEMA]);
        const tables = tablesResult.rows
            .map((row) => row.table_name)
            .filter((name) => /^[a-zA-Z0-9_]+$/.test(name)); // seguridad básica ante identificadores raros
        const backup = {
            schema: TARGET_SCHEMA,
            generated_at: new Date().toISOString(),
            columns: {},
            tables: {},
        };
        for (const table of tables) {
            const columns = yield db_1.default.query(`
                SELECT column_name, data_type, is_nullable, column_default, ordinal_position
                FROM information_schema.columns
                WHERE table_schema = $1
                  AND table_name = $2
                ORDER BY ordinal_position
                `, [TARGET_SCHEMA, table]);
            backup.columns[table] = columns.rows;
            // Nota: el volumen de datos depende del tamaño de la tabla. Para entornos grandes, migrar a streaming/CSV.
            const rows = yield db_1.default.query(`SELECT * FROM ${TARGET_SCHEMA}."${table}"`);
            backup.tables[table] = rows.rows;
        }
        const filename = `app_schema_backup_${new Date().toISOString().replace(/[:.]/g, '-')}.json`;
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
        res.status(200).send(JSON.stringify(backup, null, 2));
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al generar respaldo del esquema app' });
    }
}));
exports.default = router;
