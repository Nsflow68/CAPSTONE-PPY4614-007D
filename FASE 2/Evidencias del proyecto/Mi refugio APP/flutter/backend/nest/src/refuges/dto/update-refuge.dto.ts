import { PartialType } from '@nestjs/mapped-types';
import { CreateRefugeDto } from './create-refuge.dto';
import { IsBoolean, IsOptional } from 'class-validator';

export class UpdateRefugeDto extends PartialType(CreateRefugeDto) {
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
