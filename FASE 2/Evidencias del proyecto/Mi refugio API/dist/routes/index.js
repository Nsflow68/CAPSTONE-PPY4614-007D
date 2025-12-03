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
const auth_1 = __importDefault(require("./auth"));
const chatbot_1 = __importDefault(require("./chatbot"));
const users_1 = __importDefault(require("./users"));
const resources_1 = __importDefault(require("./resources"));
const donations_1 = __importDefault(require("./donations"));
const diary_1 = __importDefault(require("./diary"));
const maintenance_1 = __importDefault(require("./maintenance"));
const router = (0, express_1.Router)();
console.log('Cargando rutas...');
router.use('/auth', auth_1.default);
router.use('/chatbot', chatbot_1.default);
router.use('/users', users_1.default);
router.use('/resources', resources_1.default);
router.use('/donations', donations_1.default);
router.use('/diary', diary_1.default);
router.use('/maintenance', maintenance_1.default);
router.get('/health', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const result = yield db_1.default.query('SELECT NOW()');
        res.json({
            status: 'OK',
            message: 'API funcionando correctamente',
            db_time: result.rows[0].now
        });
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ status: 'ERROR', message: 'Error de conexión a la base de datos' });
    }
}));
exports.default = router;
