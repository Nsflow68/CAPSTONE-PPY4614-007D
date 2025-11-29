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
const bcrypt_1 = __importDefault(require("bcrypt"));
const router = (0, express_1.Router)();
// List all users
router.get('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const result = yield db_1.default.query('SELECT * FROM nest_backend."User" ORDER BY name');
        const users = result.rows.map(row => ({
            id: row.id,
            username: row.email,
            full_name: row.name,
            role: row.role,
            password_hash: row.password,
            // Fields not in DB, providing defaults
            gender: 'No especificado',
            age: null,
            status: 'Activo'
        }));
        res.json(users);
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener usuarios' });
    }
}));
// Create user
router.post('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { username, password, full_name, role } = req.body;
    try {
        // Generate UUID if not provided? Postgres usually handles it if default gen_random_uuid() is set.
        // But let's see if we need to provide it. The inspection showed UUIDs.
        // Let's try inserting without ID and see if it works (if default is set).
        // Also need to hash password.
        const salt = yield bcrypt_1.default.genSalt(10);
        const hash = yield bcrypt_1.default.hash(password, salt);
        // Note: nest_backend."User" might require other fields or have constraints.
        // Assuming 'email', 'password', 'name', 'role' are enough.
        const result = yield db_1.default.query('INSERT INTO nest_backend."User" (email, password, name, role, "createdAt", "updatedAt") VALUES ($1, $2, $3, $4, NOW(), NOW()) RETURNING *', [username, hash, full_name, role]);
        const row = result.rows[0];
        res.json({
            id: row.id,
            username: row.email,
            full_name: row.name,
            role: row.role,
            password_hash: row.password,
            gender: 'No especificado',
            age: null,
            status: 'Activo'
        });
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al crear usuario' });
    }
}));
// Update user
router.put('/:id', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { id } = req.params;
    const { username, full_name, role, password } = req.body;
    try {
        let query = 'UPDATE nest_backend."User" SET "updatedAt" = NOW()';
        const values = [];
        let idx = 1;
        if (username) {
            query += `, email = $${idx++}`;
            values.push(username);
        }
        if (full_name) {
            query += `, name = $${idx++}`;
            values.push(full_name);
        }
        if (role) {
            query += `, role = $${idx++}`;
            values.push(role);
        }
        if (password) {
            const salt = yield bcrypt_1.default.genSalt(10);
            const hash = yield bcrypt_1.default.hash(password, salt);
            query += `, password = $${idx++}`;
            values.push(hash);
        }
        query += ` WHERE id = $${idx} RETURNING *`;
        values.push(id);
        const result = yield db_1.default.query(query, values);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        const row = result.rows[0];
        res.json({
            id: row.id,
            username: row.email,
            full_name: row.name,
            role: row.role,
            password_hash: row.password,
            gender: 'No especificado',
            age: null,
            status: 'Activo'
        });
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al actualizar usuario' });
    }
}));
// Delete user
router.delete('/:id', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { id } = req.params;
    try {
        const result = yield db_1.default.query('DELETE FROM nest_backend."User" WHERE id = $1', [id]);
        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        res.json({ success: true });
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al eliminar usuario' });
    }
}));
exports.default = router;
