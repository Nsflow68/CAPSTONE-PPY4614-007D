import { ChatMessageDto } from './chat-message.dto';
export declare class SendMessageDto {
    message: string;
    context?: ChatMessageDto[];
}
