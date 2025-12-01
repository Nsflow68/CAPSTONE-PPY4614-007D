export declare class RefugeDto {
    id: string;
    name: string;
    description: string;
    address: string;
    phone?: string;
    email?: string;
    website?: string;
    capacity: number;
    occupied: number;
    region: string;
    commune?: string;
    latitude?: number;
    longitude?: number;
    services: string[];
    imageUrl?: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}
