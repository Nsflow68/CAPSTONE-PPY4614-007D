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
exports.RefugesController = void 0;
const common_1 = require("@nestjs/common");
const refuges_service_1 = require("./refuges.service");
const create_refuge_dto_1 = require("./dto/create-refuge.dto");
const update_refuge_dto_1 = require("./dto/update-refuge.dto");
let RefugesController = class RefugesController {
    constructor(refugesService) {
        this.refugesService = refugesService;
    }
    findAll(region, isActive) {
        return this.refugesService.findAll(region, isActive);
    }
    findOne(id) {
        return this.refugesService.findOne(id);
    }
    getStatistics(id) {
        return this.refugesService.getStatistics(id);
    }
    create(createRefugeDto) {
        return this.refugesService.create(createRefugeDto);
    }
    update(id, updateRefugeDto) {
        return this.refugesService.update(id, updateRefugeDto);
    }
    remove(id) {
        return this.refugesService.remove(id);
    }
};
exports.RefugesController = RefugesController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('region')),
    __param(1, (0, common_1.Query)('isActive', new common_1.ParseBoolPipe({ optional: true }))),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Boolean]),
    __metadata("design:returntype", void 0)
], RefugesController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], RefugesController.prototype, "findOne", null);
__decorate([
    (0, common_1.Get)(':id/statistics'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], RefugesController.prototype, "getStatistics", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_refuge_dto_1.CreateRefugeDto]),
    __metadata("design:returntype", void 0)
], RefugesController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_refuge_dto_1.UpdateRefugeDto]),
    __metadata("design:returntype", void 0)
], RefugesController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], RefugesController.prototype, "remove", null);
exports.RefugesController = RefugesController = __decorate([
    (0, common_1.Controller)('refuges'),
    __metadata("design:paramtypes", [refuges_service_1.RefugesService])
], RefugesController);
//# sourceMappingURL=refuges.controller.js.map