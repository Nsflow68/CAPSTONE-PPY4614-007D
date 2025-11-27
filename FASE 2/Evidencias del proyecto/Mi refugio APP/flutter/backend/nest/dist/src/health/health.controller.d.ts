import { HealthService } from './health.service';
export declare class HealthController {
    private readonly healthService;
    constructor(healthService: HealthService);
    getHealth(): Promise<{
        service: string;
        env: string | undefined;
        timestamp: string;
        dependencies: {
            fastapi: boolean;
        };
    }>;
}
