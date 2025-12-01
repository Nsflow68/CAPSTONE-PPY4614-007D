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
exports.AdoptionsController = void 0;
const common_1 = require("@nestjs/common");
const adoptions_service_1 = require("./adoptions.service");
const create_adoption_dto_1 = require("./dto/create-adoption.dto");
const update_adoption_dto_1 = require("./dto/update-adoption.dto");
let AdoptionsController = class AdoptionsController {
    constructor(adoptionsService) {
        this.adoptionsService = adoptionsService;
    }
    findAll(refugeId, status, petType) {
        return this.adoptionsService.findAll(refugeId, status, petType);
    }
    findOne(id) {
        return this.adoptionsService.findOne(id);
    }
    create(createAdoptionDto) {
        return this.adoptionsService.create(createAdoptionDto);
    }
    update(id, updateAdoptionDto) {
        return this.adoptionsService.update(id, updateAdoptionDto);
    }
    markAsAdopted(id, adoptedBy) {
        return this.adoptionsService.markAsAdopted(id, adoptedBy);
    }
    remove(id) {
        return this.adoptionsService.remove(id);
    }
};
exports.AdoptionsController = AdoptionsController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('refugeId')),
    __param(1, (0, common_1.Query)('status')),
    __param(2, (0, common_1.Query)('petType')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", void 0)
], AdoptionsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AdoptionsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_adoption_dto_1.CreateAdoptionDto]),
    __metadata("design:returntype", void 0)
], AdoptionsController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_adoption_dto_1.UpdateAdoptionDto]),
    __metadata("design:returntype", void 0)
], AdoptionsController.prototype, "update", null);
__decorate([
    (0, common_1.Patch)(':id/adopt'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('adoptedBy')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], AdoptionsController.prototype, "markAsAdopted", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AdoptionsController.prototype, "remove", null);
exports.AdoptionsController = AdoptionsController = __decorate([
    (0, common_1.Controller)('adoptions'),
    __metadata("design:paramtypes", [adoptions_service_1.AdoptionsService])
], AdoptionsController);
//# sourceMappingURL=adoptions.controller.js.map