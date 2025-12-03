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
const pbkdf2_1 = __importDefault(require("pbkdf2"));
const verifyDjangoPassword = (password, djangoHash) => {
    const parts = djangoHash.split('$');
    if (parts.length !== 4)
        return false;
    const [algorithm, iterationsStr, salt, hash] = parts;
    const iterations = parseInt(iterationsStr, 10);
    if (algorithm !== 'pbkdf2_sha256')
        return false;
    const derivedKey = pbkdf2_1.default.pbkdf2Sync(password, salt, iterations, 32, 'sha256');
    const derivedKeyBase64 = derivedKey.toString('base64');
    return derivedKeyBase64 === hash;
};
const testLogin = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        console.log('Buscando usuarios en web.auth_user...');
        const result = yield db_1.default.query('SELECT * FROM web.auth_user LIMIT 1');
        if (result.rows.length === 0) {
            console.log('⚠️ No hay usuarios en web.auth_user para probar.');
            return;
        }
        const user = result.rows[0];
        console.log(`Usuario encontrado: ${user.username}`);
        console.log(`Hash: ${user.password.substring(0, 20)}...`);
        console.log(`Es Staff: ${user.is_staff}`);
        // Nota: No puedo probar la contraseña real porque no la sé, 
        // pero puedo verificar que el algoritmo de hash funciona si tuviera la password.
        // Por ahora, solo confirmo que puedo leer el usuario y su hash.
        console.log('✅ Lectura de usuario exitosa.');
    }
    catch (error) {
        console.error('Error:', error);
    }
    finally {
        yield db_1.default.end();
    }
});
testLogin();
