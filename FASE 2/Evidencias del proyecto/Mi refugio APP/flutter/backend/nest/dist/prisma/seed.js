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
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const prisma = new client_1.PrismaClient();
async function main() {
    const demoEmail = process.env.DEMO_USER_EMAIL ?? 'invitado@mirefugio.cl';
    const demoPassword = await bcrypt.hash('Temporal123!', 10);
    await prisma.user.upsert({
        where: { email: demoEmail },
        update: { name: 'Invitado Mi Refugio' },
        create: {
            email: demoEmail,
            name: 'Invitado Mi Refugio',
            password: demoPassword
        }
    });
    const resourcesPath = path.join(__dirname, '..', 'src', 'resources', 'resources.data.json');
    const resources = JSON.parse(fs.readFileSync(resourcesPath, 'utf-8'));
    await prisma.resource.deleteMany();
    await prisma.resource.createMany({
        data: resources.map((item, index) => ({
            id: item.id ?? `resource-${index}`,
            name: item.name,
            description: item.description,
            category: item.category,
            coverage: item.coverage ?? null,
            contactPhone: item.contactPhone ?? null,
            contactEmail: item.contactEmail ?? null,
            website: item.website ?? null,
            region: item.region ?? null,
            tags: item.tags ?? []
        })),
        skipDuplicates: true
    });
    console.log('Seed ejecutado correctamente');
}
main()
    .catch((error) => {
    console.error('Error ejecutando seed Prisma:', error);
    process.exit(1);
})
    .finally(async () => {
    await prisma.$disconnect();
});
//# sourceMappingURL=seed.js.map