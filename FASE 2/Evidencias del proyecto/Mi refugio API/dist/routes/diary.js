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
// Obtener entradas del diario (opcionalmente filtradas por usuario)
router.get('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { userId } = req.query;
    try {
        const params = [];
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
        const result = yield db_1.default.query(query, params);
        const rows = result.rows.map(row => (Object.assign(Object.assign({}, row), { emotions: row.emotions || [], tags: row.tags || [] })));
        res.json(rows);
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener entradas del diario' });
    }
}));
exports.default = router;
