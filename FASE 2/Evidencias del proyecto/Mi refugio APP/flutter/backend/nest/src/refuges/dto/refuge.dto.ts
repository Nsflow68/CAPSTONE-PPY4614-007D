import { IsString, IsInt, IsOptional, IsBoolean, IsArray, IsNumber } from 'class-validator';

export class RefugeDto {
  @IsString()
  id: string;

  @IsString()
  name: string;

  @IsString()
  description: string;

  @IsString()
  address: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  email?: string;

  @IsOptional()
  @IsString()
  website?: string;

  @IsInt()
  capacity: number;

  @IsInt()
  occupied: number;

  @IsString()
  region: string;

  @IsOptional()
  @IsString()
  commune?: string;

  @IsOptional()
  @IsNumber()
  latitude?: number;

  @IsOptional()
  @IsNumber()
  longitude?: number;

  @IsArray()
  @IsString({ each: true })
  services: string[];

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsBoolean()
  isActive: boolean;

  createdAt: Date;
  updatedAt: Date;
}
