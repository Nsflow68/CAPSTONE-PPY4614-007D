import { PartialType } from '@nestjs/mapped-types';
import { CreateAdoptionDto } from './create-adoption.dto';
import { IsString, IsOptional, IsIn } from 'class-validator';

export class UpdateAdoptionDto extends PartialType(CreateAdoptionDto) {
  @IsOptional()
  @IsString()
  @IsIn(['available', 'pending', 'adopted', 'cancelled'])
  status?: string;

  @IsOptional()
  @IsString()
  adoptedBy?: string;
}
