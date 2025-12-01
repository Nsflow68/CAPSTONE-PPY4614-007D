import { PrismaService } from '../database/prisma.service';
import { ResourceItemDto } from './dto/resource-item.dto';
export declare class ResourcesService {
    private readonly prisma;
    private readonly resources;
    constructor(prisma: PrismaService);
    list(params: {
        q?: string;
        category?: string;
    }): Promise<{
        total: number;
        items: ResourceItemDto[];
    }>;
}
