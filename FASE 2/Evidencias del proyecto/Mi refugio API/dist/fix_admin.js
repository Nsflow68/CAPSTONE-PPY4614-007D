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
const bcrypt_1 = __importDefault(require("bcrypt"));
const fixAdmin = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const password = 'admin123';
        const salt = yield bcrypt_1.default.genSalt(10);
        const hash = yield bcrypt_1.default.hash(password, salt);
        yield db_1.default.query('UPDATE users SET password_hash = $1 WHERE username = $2', [hash, 'admin']);
        console.log('Password de admin actualizado correctamente.');
    }
    catch (error) {
        console.error('Error actualizando admin:', error);
    }
    finally {
        yield db_1.default.end();
    }
});
fixAdmin();
