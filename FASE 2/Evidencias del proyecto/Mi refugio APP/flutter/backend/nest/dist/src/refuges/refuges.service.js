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
exports.RefugesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../database/prisma.service");
let RefugesService = class RefugesService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll(region, isActive) {
        const where = {};
        if (region) {
            where.region = region;
        }
        if (isActive !== undefined) {
            where.isActive = isActive;
        }
        return this.prisma.refuge.findMany({
            where,
            include: {
                adoptions: {
                    where: { status: 'available' },
                    take: 5,
                },
            },
            orderBy: { createdAt: 'desc' },
        });
    }
    async findOne(id) {
        const refuge = await this.prisma.refuge.findUnique({
            where: { id },
            include: {
                adoptions: true,
            },
        });
        if (!refuge) {
            throw new common_1.NotFoundException(`Refugio con ID ${id} no encontrado`);
        }
        return refuge;
    }
    async create(createRefugeDto) {
        return this.prisma.refuge.create({
            data: {
                ...createRefugeDto,
                services: createRefugeDto.services || [],
            },
        });
    }
    async update(id, updateRefugeDto) {
        await this.findOne(id);
        return this.prisma.refuge.update({
            where: { id },
            data: updateRefugeDto,
        });
    }
    async remove(id) {
        await this.findOne(id);
        return this.prisma.refuge.delete({
            where: { id },
        });
    }
    async getStatistics(id) {
        const refuge = await this.findOne(id);
        const totalAdoptions = await this.prisma.adoption.count({
            where: { refugeId: id },
        });
        const adoptedCount = await this.prisma.adoption.count({
            where: { refugeId: id, status: 'adopted' },
        });
        const availableCount = await this.prisma.adoption.count({
            where: { refugeId: id, status: 'available' },
        });
        return {
            refuge: {
                id: refuge.id,
                name: refuge.name,
                capacity: refuge.capacity,
                occupied: refuge.occupied,
            },
            adoptions: {
                total: totalAdoptions,
                adopted: adoptedCount,
                available: availableCount,
            },
            occupancyRate: refuge.capacity > 0 ? (refuge.occupied / refuge.capacity) * 100 : 0,
        };
    }
};
exports.RefugesService = RefugesService;
exports.RefugesService = RefugesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], RefugesService);
//# sourceMappingURL=refuges.service.js.map