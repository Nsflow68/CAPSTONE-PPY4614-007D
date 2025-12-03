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
const checkUsers = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const schemas = ['web', 'public'];
        for (const schema of schemas) {
            const result = yield db_1.default.query(`
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_schema = $1 AND table_name = 'users';
            `, [schema]);
            console.log(`Columnas de ${schema}.users:`, result.rows.map(r => r.column_name).join(', '));
        }
    }
    catch (error) {
        console.error('Error:', error);
    }
    finally {
        yield db_1.default.end();
    }
});
checkUsers();
