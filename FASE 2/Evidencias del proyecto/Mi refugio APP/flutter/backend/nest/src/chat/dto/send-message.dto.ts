import { IsString, IsOptional, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class MessageContext {
  @IsString()
  role: string;

  @IsString()
  content: string;
}

export class SendMessageDto {
  @IsString()
  message: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => MessageContext)
  context?: MessageContext[];
}
