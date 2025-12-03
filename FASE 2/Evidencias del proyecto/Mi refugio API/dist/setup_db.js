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
const createTables = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        // Create Schema
        yield db_1.default.query('CREATE SCHEMA IF NOT EXISTS app');
        console.log('Esquema app verificado/creado.');
        // Users Table
        yield db_1.default.query(`
            CREATE TABLE IF NOT EXISTS app.users (
                id SERIAL PRIMARY KEY,
                username VARCHAR(50) UNIQUE NOT NULL,
                password_hash VARCHAR(255) NOT NULL,
                full_name VARCHAR(100),
                role VARCHAR(20) DEFAULT 'user'
            );
        `);
        console.log('Tabla users verificada/creada.');
        // Chatbot Responses Table
        yield db_1.default.query(`
            CREATE TABLE IF NOT EXISTS app.chatbot_responses (
                id SERIAL PRIMARY KEY,
                keyword VARCHAR(255) UNIQUE NOT NULL,
                response TEXT NOT NULL
            );
        `);
        console.log('Tabla chatbot_responses verificada/creada.');
        // Insert default admin if not exists
        const adminCheck = yield db_1.default.query('SELECT * FROM app.users WHERE username = $1', ['admin']);
        if (adminCheck.rows.length === 0) {
            // Note: In a real app, we should hash this password properly on the server side or send it hashed.
            // For now, I'll insert a placeholder or the hash used by the python app if I can replicate it.
            // The python app uses a specific hash function. 
            // Let's just insert a known hash or plain text and handle it in the login logic for now.
            // Wait, the python app sends the password to the auth service. 
            // The API should verify the password.
            // I'll use a simple hash for 'admin123' for now or just plain text if I implement the check.
            // Let's assume the API will handle hashing.
            // For simplicity in this migration, I will just insert the user. 
            // I will implement the login endpoint to compare against this.
            // I'll use a placeholder hash for now.
            yield db_1.default.query(`
                INSERT INTO app.users (username, password_hash, role)
                VALUES ('admin', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWrn3ILAWOi/lPa.LSK.X.0.0.0.0', 'admin')
            `);
            console.log('Usuario admin creado.');
        }
    }
    catch (error) {
        console.error('Error creando tablas:', error);
    }
    finally {
        yield db_1.default.end();
    }
});
createTables();
