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
const migrateToApp = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        console.log('Iniciando migración al esquema "app"...');
        // 1. Crear esquema app
        yield db_1.default.query('CREATE SCHEMA IF NOT EXISTS app');
        console.log('Esquema "app" creado.');
        // 2. Mover tablas de nest_backend
        const nestTables = ['User', 'Resource', 'DiaryEntry', 'HydrationLog'];
        for (const table of nestTables) {
            try {
                yield db_1.default.query(`ALTER TABLE nest_backend."${table}" SET SCHEMA app`);
                console.log(`Tabla nest_backend."${table}" movida a app.`);
            }
            catch (e) {
                console.log(`Nota: No se pudo mover nest_backend."${table}" (quizás no existe).`);
            }
        }
        // 3. Mover tablas de dw
        const dwTables = ['dim_date', 'dim_user', 'fact_donation', 'fact_emotion', 'fact_meal'];
        for (const table of dwTables) {
            try {
                yield db_1.default.query(`ALTER TABLE dw.${table} SET SCHEMA app`);
                console.log(`Tabla dw.${table} movida a app.`);
            }
            catch (e) {
                console.log(`Nota: No se pudo mover dw.${table} (quizás no existe).`);
            }
        }
        // 4. Mover tablas de API
        const apiTables = ['users', 'chatbot_responses'];
        for (const table of apiTables) {
            try {
                yield db_1.default.query(`ALTER TABLE "API".${table} SET SCHEMA app`);
                console.log(`Tabla API.${table} movida a app.`);
            }
            catch (e) {
                console.log(`Nota: No se pudo mover API.${table} (quizás no existe).`);
            }
        }
        // 5. Eliminar esquemas antiguos (si están vacíos)
        const schemas = ['nest_backend', 'dw', 'API', 'core', 'mobile'];
        for (const schema of schemas) {
            try {
                yield db_1.default.query(`DROP SCHEMA IF EXISTS "${schema}" CASCADE`);
                console.log(`Esquema "${schema}" eliminado.`);
            }
            catch (e) {
                console.error(`Error eliminando esquema "${schema}":`, e);
            }
        }
    }
    catch (error) {
        console.error('Error crítico en la migración:', error);
    }
    finally {
        yield db_1.default.end();
    }
});
migrateToApp();
