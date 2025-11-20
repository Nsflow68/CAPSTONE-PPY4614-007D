import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma.service';
import resourcesData from './resources.data.json';
import { ResourceItemDto } from './dto/resource-item.dto';

@Injectable()
export class ResourcesService {
  private readonly resources: ResourceItemDto[] = resourcesData as ResourceItemDto[];

  constructor(private readonly prisma: PrismaService) {}

  async list(params: { q?: string; category?: string }) {
    const term = params.q?.toLowerCase().trim();
    const category = params.category?.toLowerCase().trim();

    if (this.prisma.isHealthy) {
      const where: Prisma.ResourceWhereInput = {};
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
        items: items.map<ResourceItemDto>((item) => ({
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
      const matchesTerm =
        !term ||
        item.name.toLowerCase().includes(term) ||
        item.description.toLowerCase().includes(term);
      return matchesCategory && matchesTerm;
    });

    return {
      total: items.length,
      items,
    };
  }
}
