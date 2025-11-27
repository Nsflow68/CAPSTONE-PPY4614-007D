"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.HydrationController = void 0;
const common_1 = require("@nestjs/common");
const hydration_service_1 = require("./hydration.service");
const register_intake_dto_1 = require("./dto/register-intake.dto");
let HydrationController = class HydrationController {
    constructor(hydrationService) {
        this.hydrationService = hydrationService;
    }
    getWeeklyIntake() {
        return this.hydrationService.listWeeklyIntake();
    }
    getToday() {
        return this.hydrationService.getTodayIntake();
    }
    register(dto) {
        return this.hydrationService.registerIntake(dto);
    }
};
exports.HydrationController = HydrationController;
__decorate([
    (0, common_1.Get)('weekly'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], HydrationController.prototype, "getWeeklyIntake", null);
__decorate([
    (0, common_1.Get)('today'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], HydrationController.prototype, "getToday", null);
__decorate([
    (0, common_1.Post)('register'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [register_intake_dto_1.RegisterIntakeDto]),
    __metadata("design:returntype", void 0)
], HydrationController.prototype, "register", null);
exports.HydrationController = HydrationController = __decorate([
    (0, common_1.Controller)('hydration'),
    __metadata("design:paramtypes", [hydration_service_1.HydrationService])
], HydrationController);
//# sourceMappingURL=hydration.controller.js.map