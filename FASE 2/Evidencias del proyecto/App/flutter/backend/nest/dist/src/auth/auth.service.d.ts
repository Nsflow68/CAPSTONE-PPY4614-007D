import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../database/prisma.service';
import { LoginDto } from './dto/login.dto';
import { SignupDto } from './dto/signup.dto';
type UserRole = 'member' | 'therapist' | 'admin';
export declare class AuthService {
    private readonly prisma;
    private readonly jwt;
    private readonly fallbackUser;
    private readonly defaultClient;
    private readonly defaultRole;
    private readonly clientAccessMatrix;
    private readonly knownRoles;
    constructor(prisma: PrismaService, jwt: JwtService);
    login(payload: LoginDto): Promise<{
        accessToken: string;
        client: "mobile" | "web" | "desktop";
        user: {
            id: string;
            email: string;
            name: string;
            role: UserRole;
        };
    }>;
    signup(payload: SignupDto): Promise<{
        accessToken: string;
        client: "mobile" | "web" | "desktop";
        user: {
            id: string;
            email: string;
            name: string;
            role: UserRole;
        };
    }>;
    private buildAuthPayload;
    private normalizeClient;
    private normalizeRole;
    private ensureClientAccess;
}
export {};
