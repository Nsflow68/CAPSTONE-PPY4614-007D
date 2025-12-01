export declare class AdoptionDto {
    id: string;
    petName: string;
    petType: string;
    petBreed?: string;
    petAge?: number;
    petGender?: string;
    description: string;
    imageUrl?: string;
    status: string;
    adoptedBy?: string;
    adoptedAt?: Date;
    refugeId: string;
    createdAt: Date;
    updatedAt: Date;
}
