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
const alterTables = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        console.log('Iniciando modificación de tablas...');
        // 1. Modificar DiaryEntry
        yield db_1.default.query(`
            ALTER TABLE app."DiaryEntry" 
            DROP COLUMN IF EXISTS "userId",
            ADD COLUMN "userId" INTEGER,
            ADD CONSTRAINT fk_diary_user FOREIGN KEY ("userId") REFERENCES web.auth_user(id);
        `);
        console.log('✅ app."DiaryEntry" actualizada.');
        // 2. Modificar HydrationLog
        yield db_1.default.query(`
            ALTER TABLE app."HydrationLog" 
            DROP COLUMN IF EXISTS "userId",
            ADD COLUMN "userId" INTEGER,
            ADD CONSTRAINT fk_hydration_user FOREIGN KEY ("userId") REFERENCES web.auth_user(id);
        `);
        console.log('✅ app."HydrationLog" actualizada.');
        // 3. Eliminar tablas de usuarios redundantes en app
        yield db_1.default.query('DROP TABLE IF EXISTS app.users CASCADE');
        yield db_1.default.query('DROP TABLE IF EXISTS app."User" CASCADE');
        console.log('✅ Tablas redundantes (app.users, app.User) eliminadas.');
    }
    catch (error) {
        console.error('Error modificando tablas:', error);
    }
    finally {
        yield db_1.default.end();
    }
});
alterTables();
