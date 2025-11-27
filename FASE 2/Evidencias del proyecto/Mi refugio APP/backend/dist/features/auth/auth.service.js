"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
let AuthService = class AuthService {
    constructor() {
        this.mockUsers = [
            {
                id: '1',
                email: 'mateo.flores@mirefugio.cl',
                name: 'Mateo Flores',
                role: 'Ciudadano',
            },
        ];
    }
    login(dto) {
        var _a;
        const user = (_a = this.mockUsers.find((u) => u.email.toLowerCase() === dto.email.toLowerCase())) !== null && _a !== void 0 ? _a : this.mockUsers[0];
        return {
            accessToken: 'mock-jwt-token',
            user,
        };
    }
    guestAccess() {
        return {
            accessToken: 'guest-token',
            user: {
                id: 'guest',
                email: 'invitado@mirefugio.cl',
                name: 'Invitado',
                role: 'Invitado',
            },
        };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)()
], AuthService);
//# sourceMappingURL=auth.service.js.map