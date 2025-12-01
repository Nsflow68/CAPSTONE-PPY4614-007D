"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdoptionsModule = void 0;
const common_1 = require("@nestjs/common");
const adoptions_controller_1 = require("./adoptions.controller");
const adoptions_service_1 = require("./adoptions.service");
const prisma_module_1 = require("../database/prisma.module");
let AdoptionsModule = class AdoptionsModule {
};
exports.AdoptionsModule = AdoptionsModule;
exports.AdoptionsModule = AdoptionsModule = __decorate([
    (0, common_1.Module)({
        imports: [prisma_module_1.PrismaModule],
        controllers: [adoptions_controller_1.AdoptionsController],
        providers: [adoptions_service_1.AdoptionsService],
        exports: [adoptions_service_1.AdoptionsService],
    })
], AdoptionsModule);
//# sourceMappingURL=adoptions.module.js.map