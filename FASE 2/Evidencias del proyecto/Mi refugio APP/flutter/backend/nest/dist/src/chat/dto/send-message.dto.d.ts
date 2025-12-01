declare class MessageContext {
    role: string;
    content: string;
}
export declare class SendMessageDto {
    message: string;
    context?: MessageContext[];
}
export {};
