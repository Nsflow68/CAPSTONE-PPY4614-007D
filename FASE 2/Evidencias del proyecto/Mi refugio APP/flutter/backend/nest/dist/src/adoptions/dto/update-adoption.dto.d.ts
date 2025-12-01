import { CreateAdoptionDto } from './create-adoption.dto';
declare const UpdateAdoptionDto_base: import("@nestjs/mapped-types").MappedType<Partial<CreateAdoptionDto>>;
export declare class UpdateAdoptionDto extends UpdateAdoptionDto_base {
    status?: string;
    adoptedBy?: string;
}
export {};
