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
const COLUMN_QUERY = `
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'web'
      AND table_name = 'payments_donation'
`;
router.get('/', (_req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b;
    try {
        const columnsResult = yield db_1.default.query(COLUMN_QUERY);
        const columns = columnsResult.rows.map((row) => row.column_name);
        const hasCurrency = columns.includes('currency');
        const hasMessage = columns.includes('message');
        const fields = ['id', 'name', 'email', 'created_at', 'amount'];
        if (hasCurrency) {
            fields.push('currency');
        }
        if (hasMessage) {
            fields.push('message');
        }
        const dataResult = yield db_1.default.query(`
            SELECT ${fields.join(', ')}
            FROM web.payments_donation
            ORDER BY created_at DESC NULLS LAST, id DESC
            LIMIT 200
        `);
        const totalResult = yield db_1.default.query('SELECT COALESCE(SUM(amount), 0) AS total_amount FROM web.payments_donation');
        const currencyRow = hasCurrency ? dataResult.rows.find((row) => row.currency) || {} : {};
        res.json({
            columns: ['id', 'created_at', 'amount', 'name', 'email']
                .concat(hasCurrency ? ['currency'] : [])
                .concat(hasMessage ? ['message'] : []),
            total_records: dataResult.rowCount,
            total_amount: Number((_b = (_a = totalResult.rows[0]) === null || _a === void 0 ? void 0 : _a.total_amount) !== null && _b !== void 0 ? _b : 0),
            currency: currencyRow.currency || null,
            data: dataResult.rows,
        });
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error al obtener donaciones' });
    }
}));
exports.default = router;
