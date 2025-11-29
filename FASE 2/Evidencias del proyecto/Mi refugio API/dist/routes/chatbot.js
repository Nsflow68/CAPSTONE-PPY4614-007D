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
// List all entries
router.get('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const result = yield db_1.default.query('SELECT * FROM chatbot_responses ORDER BY keyword');
        res.json(result.rows);
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener datos' });
    }
}));
// Create entry
router.post('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { keyword, response } = req.body;
    try {
        const result = yield db_1.default.query('INSERT INTO chatbot_responses (keyword, response) VALUES ($1, $2) RETURNING *', [keyword, response]);
        res.json(result.rows[0]);
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al crear registro' });
    }
}));
// Update entry
router.put('/:id', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { id } = req.params;
    const { keyword, response } = req.body;
    try {
        const result = yield db_1.default.query('UPDATE chatbot_responses SET keyword = $1, response = $2 WHERE id = $3 RETURNING *', [keyword, response, id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Registro no encontrado' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al actualizar registro' });
    }
}));
// Delete entry
router.delete('/:id', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { id } = req.params;
    try {
        const result = yield db_1.default.query('DELETE FROM chatbot_responses WHERE id = $1', [id]);
        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Registro no encontrado' });
        }
        res.json({ success: true });
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al eliminar registro' });
    }
}));
exports.default = router;
