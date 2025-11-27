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
exports.MindfulnessController = void 0;
const common_1 = require("@nestjs/common");
const mindfulness_service_1 = require("./mindfulness.service");
const pagination_dto_1 = require("../common/dto/pagination.dto");
let MindfulnessController = class MindfulnessController {
    constructor(mindfulnessService) {
        this.mindfulnessService = mindfulnessService;
    }
    getSessions(pagination) {
        return this.mindfulnessService.listSessions(pagination);
    }
    getHighlights() {
        return this.mindfulnessService.getHighlights();
    }
};
exports.MindfulnessController = MindfulnessController;
__decorate([
    (0, common_1.Get)('sessions'),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [pagination_dto_1.PaginationDto]),
    __metadata("design:returntype", void 0)
], MindfulnessController.prototype, "getSessions", null);
__decorate([
    (0, common_1.Get)('highlights'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], MindfulnessController.prototype, "getHighlights", null);
exports.MindfulnessController = MindfulnessController = __decorate([
    (0, common_1.Controller)('mindfulness'),
    __metadata("design:paramtypes", [mindfulness_service_1.MindfulnessService])
], MindfulnessController);
//# sourceMappingURL=mindfulness.controller.js.map