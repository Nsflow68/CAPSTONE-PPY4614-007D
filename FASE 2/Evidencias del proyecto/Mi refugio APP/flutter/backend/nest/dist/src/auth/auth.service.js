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
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const bcrypt = __importStar(require("bcryptjs"));
const jwt_1 = require("@nestjs/jwt");
const crypto_1 = require("crypto");
const prisma_service_1 = require("../database/prisma.service");
let AuthService = class AuthService {
    constructor(prisma, jwt) {
        this.prisma = prisma;
        this.jwt = jwt;
        this.fallbackUser = {
            id: 'demo-user',
            email: 'demo@mirefugio.cl',
            name: 'Usuario Mi Refugio',
            role: 'member',
        };
        this.defaultClient = 'mobile';
        this.defaultRole = 'member';
        this.clientAccessMatrix = {
            mobile: ['member', 'admin'],
            web: ['member', 'admin'],
            desktop: ['therapist', 'admin'],
        };
        this.knownRoles = ['member', 'therapist', 'admin'];
    }
    async login(payload) {
        const client = this.normalizeClient(payload.client);
        if (this.prisma.isHealthy) {
            const user = await this.prisma.user.findUnique({
                where: { email: payload.email },
            });
            if (!user) {
                throw new common_1.UnauthorizedException('invalid_credentials');
            }
            const passwordOk = await bcrypt.compare(payload.password, user.password);
            if (!passwordOk) {
                throw new common_1.UnauthorizedException('invalid_credentials');
            }
            const userRole = this.normalizeRole(user.role);
            this.ensureClientAccess(userRole, client);
            return this.buildAuthPayload(user.id, user.email, user.name, userRole, client);
        }
        this.ensureClientAccess(this.fallbackUser.role, client);
        return this.buildAuthPayload(this.fallbackUser.id, payload.email, this.fallbackUser.name, this.fallbackUser.role, client);
    }
    async signup(payload) {
        const client = this.normalizeClient(payload.client);
        if (this.prisma.isHealthy) {
            const exists = await this.prisma.user.findUnique({
                where: { email: payload.email },
            });
            if (exists) {
                throw new common_1.BadRequestException('email_already_registered');
            }
            const hashed = await bcrypt.hash(payload.password, 10);
            const user = await this.prisma.user.create({
                data: {
                    email: payload.email,
                    name: payload.name,
                    password: hashed,
                    role: this.defaultRole,
                    avatarUrl: null,
                },
            });
            return this.buildAuthPayload(user.id, user.email, user.name, this.defaultRole, client);
        }
        this.ensureClientAccess(this.defaultRole, client);
        return this.buildAuthPayload((0, crypto_1.randomUUID)(), payload.email, payload.name, this.defaultRole, client);
    }
    buildAuthPayload(id, email, name, role, client) {
        return {
            accessToken: this.jwt.sign({ sub: id, email, role, client }),
            client,
            user: { id, email, name, role },
        };
    }
    normalizeClient(client) {
        if (!client) {
            return this.defaultClient;
        }
        return this.clientAccessMatrix[client] ? client : this.defaultClient;
    }
    normalizeRole(role) {
        if (!role) {
            return this.defaultRole;
        }
        return this.knownRoles.includes(role) ? role : this.defaultRole;
    }
    ensureClientAccess(role, client) {
        const allowedRoles = this.clientAccessMatrix[client];
        if (!allowedRoles.includes(role)) {
            throw new common_1.UnauthorizedException('role_not_allowed_for_client');
        }
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map