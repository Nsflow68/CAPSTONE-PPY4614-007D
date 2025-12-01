"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const bcrypt = __importStar(require("bcryptjs"));
async function main() {
    const prisma = new client_1.PrismaClient({
        datasources: {
            db: {
                url: process.env.DATABASE_URL,
            },
        },
        log: ['query', 'info', 'warn', 'error'],
    });
    try {
        console.log('Conectando...');
        await prisma.$connect();
        const email = `test-${Date.now()}@example.com`;
        const password = 'password123';
        const hashed = await bcrypt.hash(password, 10);
        console.log(`Intentando crear usuario: ${email}`);
        const user = await prisma.user.create({
            data: {
                email: email,
                name: 'Test User',
                password: hashed,
                role: 'member',
                avatarUrl: null,
            },
        });
        console.log('¡Usuario creado exitosamente!');
        console.log(user);
    }
    catch (e) {
        console.error('ERROR AL CREAR USUARIO:');
        console.error(e);
    }
    finally {
        await prisma.$disconnect();
    }
}
main();
//# sourceMappingURL=test-signup.js.map