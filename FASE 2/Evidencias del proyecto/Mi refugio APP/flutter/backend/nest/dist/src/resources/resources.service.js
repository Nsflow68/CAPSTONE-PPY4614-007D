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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ResourcesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../database/prisma.service");
const resources_data_json_1 = __importDefault(require("./resources.data.json"));
let ResourcesService = class ResourcesService {
    constructor(prisma) {
        this.prisma = prisma;
        this.resources = resources_data_json_1.default;
    }
    async list(params) {
        const term = params.q?.toLowerCase().trim();
        const category = params.category?.toLowerCase().trim();
        if (this.prisma.isHealthy) {
            const where = {};
            if (term) {
                where.OR = [
                    { name: { contains: term, mode: 'insensitive' } },
                    { description: { contains: term, mode: 'insensitive' } },
                ];
            }
            if (category) {
                where.category = { equals: category, mode: 'insensitive' };
            }
            const [items, total] = await this.prisma.$transaction([
                this.prisma.resource.findMany({
                    where,
                    orderBy: { name: 'asc' },
                }),
                this.prisma.resource.count({ where }),
            ]);
            return {
                total,
                items: items.map((item) => ({
                    id: item.id,
                    name: item.name,
                    description: item.description,
                    coverage: item.coverage ?? undefined,
                    category: item.category,
                    contactPhone: item.contactPhone ?? undefined,
                    contactEmail: item.contactEmail ?? undefined,
                    website: item.website ?? undefined,
                    region: item.region ?? undefined,
                    tags: item.tags,
                })),
            };
        }
        const items = this.resources.filter((item) => {
            const matchesCategory = !category || item.category.toLowerCase() === category;
            const matchesTerm = !term ||
                item.name.toLowerCase().includes(term) ||
                item.description.toLowerCase().includes(term);
            return matchesCategory && matchesTerm;
        });
        return {
            total: items.length,
            items,
        };
    }
};
exports.ResourcesService = ResourcesService;
exports.ResourcesService = ResourcesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ResourcesService);
//# sourceMappingURL=resources.service.js.map