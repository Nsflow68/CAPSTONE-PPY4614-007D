import { IsString, IsInt, IsOptional, Min } from 'class-validator';

export class CreateAdoptionDto {
  @IsString()
  petName: string;

  @IsString()
  petType: string;

  @IsOptional()
  @IsString()
  petBreed?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
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
  refugeId: string;
}
