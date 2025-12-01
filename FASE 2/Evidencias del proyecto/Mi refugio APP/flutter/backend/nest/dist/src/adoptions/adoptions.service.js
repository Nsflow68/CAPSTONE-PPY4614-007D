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
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdoptionsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../database/prisma.service");
let AdoptionsService = class AdoptionsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll(refugeId, status, petType) {
        const where = {};
        if (refugeId) {
            where.refugeId = refugeId;
        }
        if (status) {
            where.status = status;
        }
        if (petType) {
            where.petType = petType;
        }
        return this.prisma.adoption.findMany({
            where,
            include: {
                refuge: {
                    select: {
                        id: true,
                        name: true,
                        region: true,
                        phone: true,
                        email: true,
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
        });
    }
    async findOne(id) {
        const adoption = await this.prisma.adoption.findUnique({
            where: { id },
            include: {
                refuge: true,
            },
        });
        if (!adoption) {
            throw new common_1.NotFoundException(`Adopción con ID ${id} no encontrada`);
        }
        return adoption;
    }
    async create(createAdoptionDto) {
        return this.prisma.adoption.create({
            data: createAdoptionDto,
            include: {
                refuge: true,
            },
        });
    }
    async update(id, updateAdoptionDto) {
        await this.findOne(id);
        const data = { ...updateAdoptionDto };
        if (updateAdoptionDto.status === 'adopted' && !data.adoptedAt) {
            data.adoptedAt = new Date();
        }
        return this.prisma.adoption.update({
            where: { id },
            data,
            include: {
                refuge: true,
            },
        });
    }
    async remove(id) {
        await this.findOne(id);
        return this.prisma.adoption.delete({
            where: { id },
        });
    }
    async markAsAdopted(id, adoptedBy) {
        return this.update(id, {
            status: 'adopted',
            adoptedBy,
        });
    }
};
exports.AdoptionsService = AdoptionsService;
exports.AdoptionsService = AdoptionsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AdoptionsService);
//# sourceMappingURL=adoptions.service.js.map