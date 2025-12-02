import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
    private readonly logger = new Logger(AllExceptionsFilter.name);

    catch(exception: unknown, host: ArgumentsHost) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse<Response>();
        const request = ctx.getRequest<Request>();

        const status =
            exception instanceof HttpException
                ? exception.getStatus()
                : HttpStatus.INTERNAL_SERVER_ERROR;

        const message =
            exception instanceof HttpException
                ? exception.getResponse()
                : exception;

        this.logger.error(
            `Http Status: ${status} Error Message: ${JSON.stringify(message)}`,
        );

        // Force console output for debugging
        console.error('=== EXCEPTION CAUGHT ===');
        console.error('Status:', status);
        console.error('Message:', JSON.stringify(message, null, 2));
        console.error('Exception:', exception);

        if (exception instanceof Error) {
            this.logger.error(exception.stack);
            console.error('Stack:', exception.stack);
        }

        const responseBody = {
            statusCode: status,
            timestamp: new Date().toISOString(),
            path: request.url,
            message: exception instanceof HttpException ? (message as any).message || message : 'Internal server error',
            error: exception instanceof HttpException ? (message as any).error : undefined,
        };

        response.status(status).json(responseBody);
    }
}
