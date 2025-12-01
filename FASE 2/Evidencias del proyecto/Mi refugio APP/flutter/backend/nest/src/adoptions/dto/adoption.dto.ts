import { IsString, IsInt, IsOptional, IsDateString } from 'class-validator';

export class AdoptionDto {
  @IsString()
  id: string;

  @IsString()
  petName: string;

  @IsString()
  petType: string;

  @IsOptional()
  @IsString()
  petBreed?: string;

  @IsOptional()
  @IsInt()
  petAge?: number;

  @IsOptional()
  @IsString()
  petGender?: string;

  @IsString()
  description: string;

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsString()
  status: string;

  @IsOptional()
  @IsString()
  adoptedBy?: string;

  @IsOptional()
  @IsDateString()
  adoptedAt?: Date;

  @IsString()
  refugeId: string;

  createdAt: Date;
  updatedAt: Date;
}
