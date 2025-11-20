export interface ProfessionalResource {
    id: string;
    title: string;
    subtitle: string;
    category: string;
    description: string;
    contact?: string;
    website?: string;
}
export declare class ResourcesService {
    private readonly resources;
    findAll(category?: string): ProfessionalResource[];
}
