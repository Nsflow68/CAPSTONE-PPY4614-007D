import { ConfigService } from '@nestjs/config';
import { User } from '@prisma/client';
import { PrismaService } from '../database/prisma.service';
export declare class DemoUserService {
    private readonly prisma;
    private readonly configService;
    private cachedUser?;
    constructor(prisma: PrismaService, configService: ConfigService);
    getUser(): Promise<User>;
    getUserId(): Promise<string>;
    private get demoEmail();
}
