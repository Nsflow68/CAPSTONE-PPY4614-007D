import { ResourcesService } from './resources.service';
export declare class ResourcesController {
    private readonly resourcesService;
    constructor(resourcesService: ResourcesService);
    list(q?: string, category?: string): Promise<{
        total: number;
        items: import("./dto/resource-item.dto").ResourceItemDto[];
    }>;
}
