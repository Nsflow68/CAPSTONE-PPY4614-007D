import { Injectable } from '@nestjs/common';
import resourcesData from './resources.data.json';
import { ResourceItemDto } from './dto/resource-item.dto';

@Injectable()
export class ResourcesService {
  private readonly resources: ResourceItemDto[] =
    resourcesData as ResourceItemDto[];

  list(params: { q?: string; category?: string }) {
    const term = params.q?.toLowerCase().trim();
    const category = params.category?.toLowerCase().trim();

    const items = this.resources.filter((item) => {
      const matchesCategory =
        !category || item.category.toLowerCase() === category;
      const matchesTerm =
        !term ||
        item.name.toLowerCase().includes(term) ||
        item.description.toLowerCase().includes(term);
      return matchesCategory && matchesTerm;
    });

    return {
      total: items.length,
      items
    };
  }
}
