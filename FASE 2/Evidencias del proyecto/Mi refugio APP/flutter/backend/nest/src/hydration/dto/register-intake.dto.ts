import { IsInt, IsISO8601, IsOptional, Max, Min } from 'class-validator';

export class RegisterIntakeDto {
  @IsInt()
  @Min(50)
  @Max(2000)
  amountMl!: number;

  @IsOptional()
  @IsISO8601()
  date?: string;
}
