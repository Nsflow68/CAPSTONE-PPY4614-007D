import { IsIn, IsOptional, IsString } from 'class-validator';

export class ChatMessageDto {
  @IsIn(['user', 'assistant'])
  role!: 'user' | 'assistant';

  @IsString()
  content!: string;

  @IsOptional()
  @IsString()
  createdAt?: string;
}
