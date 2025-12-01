"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
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
        console.log('Intentando conectar a la base de datos...');
        console.log('URL:', process.env.DATABASE_URL?.replace(/:[^:]*@/, ':****@'));
        await prisma.$connect();
        console.log('¡Conexión exitosa con Prisma!');
        const count = await prisma.user.count();
        console.log(`Número de usuarios en la base de datos: ${count}`);
    }
    catch (e) {
        console.error('Error al conectar con la base de datos:', e);
    }
    finally {
        await prisma.$disconnect();
    }
}
main();
//# sourceMappingURL=test-db-connection.js.map