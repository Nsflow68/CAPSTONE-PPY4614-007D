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
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
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
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DemoUserService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const bcrypt = __importStar(require("bcryptjs"));
const prisma_service_1 = require("../database/prisma.service");
let DemoUserService = class DemoUserService {
    constructor(prisma, configService) {
        this.prisma = prisma;
        this.configService = configService;
    }
    async getUser() {
        if (!this.prisma.isHealthy) {
            return {
                id: 'demo-user',
                email: this.demoEmail,
                name: 'Invitado Mi Refugio',
                avatarUrl: null,
                createdAt: new Date(),
                updatedAt: new Date(),
                password: 'demo',
                role: 'member',
            };
        }
        if (this.cachedUser) {
            return this.cachedUser;
        }
        const hashed = await bcrypt.hash('Temporal123!', 10);
        const user = await this.prisma.user.upsert({
            where: { email: this.demoEmail },
            update: { name: 'Invitado Mi Refugio' },
            create: {
                email: this.demoEmail,
                name: 'Invitado Mi Refugio',
                password: hashed,
                avatarUrl: null,
                role: 'member',
            },
        });
        this.cachedUser = user;
        return user;
    }
    async getUserId() {
        const user = await this.getUser();
        return user.id;
    }
    get demoEmail() {
        return this.configService.get('demoUserEmail') ?? 'invitado@mirefugio.cl';
    }
};
exports.DemoUserService = DemoUserService;
exports.DemoUserService = DemoUserService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        config_1.ConfigService])
], DemoUserService);
//# sourceMappingURL=demo-user.service.js.map