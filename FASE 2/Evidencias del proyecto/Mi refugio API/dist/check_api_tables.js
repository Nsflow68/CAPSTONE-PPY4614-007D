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
const checkTables = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const result = yield db_1.default.query(`
            SELECT table_schema, table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'API'
            ORDER BY table_name;
        `);
        console.log('Tablas encontradas en el esquema API:');
        if (result.rows.length === 0) {
            console.log('No se encontraron tablas en el esquema API.');
        }
        else {
            result.rows.forEach(row => {
                console.log(`${row.table_schema}.${row.table_name}`);
            });
        }
    }
    catch (error) {
        console.error('Error buscando tablas:', error);
    }
    finally {
        yield db_1.default.end();
    }
});
checkTables();
