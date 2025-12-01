import { CreateRefugeDto } from './create-refuge.dto';
declare const UpdateRefugeDto_base: import("@nestjs/mapped-types").MappedType<Partial<CreateRefugeDto>>;
export declare class UpdateRefugeDto extends UpdateRefugeDto_base {
    isActive?: boolean;
}
export {};
