import { Injectable, NestMiddleware, Logger } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
    private logger = new Logger('HTTP');

    use(req: Request, res: Response, next: NextFunction) {
        const { ip, method, originalUrl, body } = req;
        const userAgent = req.get('user-agent') || '';

        this.logger.log(
            `Incoming Request: ${method} ${originalUrl} - Body: ${JSON.stringify(body)} - User-Agent: ${userAgent} - IP: ${ip}`
        );

        res.on('finish', () => {
            const { statusCode } = res;
            this.logger.log(
                `Response: ${method} ${originalUrl} ${statusCode}`
            );
        });

        next();
    }
}
