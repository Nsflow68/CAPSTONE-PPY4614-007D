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
const checkDjangoUser = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        // Check if table exists
        const tableRes = yield db_1.default.query(`
            SELECT table_schema, table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'web' AND table_name = 'auth_user'
        `);
        if (tableRes.rows.length === 0) {
            console.log('❌ La tabla web.auth_user NO existe.');
            return;
        }
        console.log('✅ La tabla web.auth_user existe.');
        // Check columns
        const result = yield db_1.default.query(`
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_schema = 'web' AND table_name = 'auth_user'
        `);
        console.log('Columnas de web.auth_user:');
        result.rows.forEach(row => {
            console.log(`${row.column_name} (${row.data_type})`);
        });
    }
    catch (error) {
        console.error('Error:', error);
    }
    finally {
        yield db_1.default.end();
    }
});
checkDjangoUser();
