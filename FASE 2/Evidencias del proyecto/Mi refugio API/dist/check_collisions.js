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
const db_1 = __importDefault(require("./config/db"));
const checkCollisions = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const schemas = ['nest_backend', 'core', 'dw', 'mobile'];
        const result = yield db_1.default.query(`
            SELECT table_schema, table_name 
            FROM information_schema.tables 
            WHERE table_schema = ANY($1)
        `, [schemas]);
        const tables = {};
        result.rows.forEach(row => {
            if (!tables[row.table_name]) {
                tables[row.table_name] = [];
            }
            tables[row.table_name].push(row.table_schema);
        });
        console.log('--- Análisis de Tablas ---');
        let collisions = false;
        for (const [tableName, foundSchemas] of Object.entries(tables)) {
            if (foundSchemas.length > 1) {
                console.log(`⚠️ COLISIÓN: La tabla '${tableName}' existe en: ${foundSchemas.join(', ')}`);
                collisions = true;
            }
            else {
                console.log(`✅ '${tableName}' solo en ${foundSchemas[0]}`);
            }
        }
        if (!collisions) {
            console.log('✨ No se encontraron colisiones de nombres. Es seguro fusionar.');
        }
    }
    catch (error) {
        console.error('Error:', error);
    }
    finally {
        yield db_1.default.end();
    }
});
checkCollisions();
