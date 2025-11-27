import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
export declare class HealthService {
    private readonly httpService;
    private readonly configService;
    constructor(httpService: HttpService, configService: ConfigService);
    check(): Promise<{
        service: string;
        env: string | undefined;
        timestamp: string;
        dependencies: {
            fastapi: boolean;
        };
    }>;
}
