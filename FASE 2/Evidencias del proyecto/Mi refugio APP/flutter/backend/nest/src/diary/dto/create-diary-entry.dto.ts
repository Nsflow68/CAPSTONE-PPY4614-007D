import { IsArray, IsDateString, IsInt, IsNotEmpty, IsString, Max, Min } from 'class-validator';

export class CreateDiaryEntryDto {
  @IsString()
  @IsNotEmpty()
  title!: string;

  @IsString()
  @IsNotEmpty()
  content!: string;

  @IsString()
  @IsNotEmpty()
  mood!: string;

  @IsInt()
  @Min(1)
  @Max(10)
  score!: number;

  @IsString()
  moodText!: string;

  @IsDateString()
  date!: string;

  @IsArray()
  emotions!: string[];

  @IsArray()
  tags!: string[];
}
