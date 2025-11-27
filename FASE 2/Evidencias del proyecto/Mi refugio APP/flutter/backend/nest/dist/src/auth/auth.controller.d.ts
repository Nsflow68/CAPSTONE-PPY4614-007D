import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { SignupDto } from './dto/signup.dto';
type AuthenticatedRequest = {
    user: {
        id: string;
        email: string;
        name?: string;
    };
};
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    login(payload: LoginDto): Promise<{
        accessToken: string;
        client: "mobile" | "web" | "desktop";
        user: {
            id: string;
            email: string;
            name: string;
            role: "member" | "therapist" | "admin";
        };
    }>;
    signup(payload: SignupDto): Promise<{
        accessToken: string;
        client: "mobile" | "web" | "desktop";
        user: {
            id: string;
            email: string;
            name: string;
            role: "member" | "therapist" | "admin";
        };
    }>;
    me(req: AuthenticatedRequest): {
        id: string;
        email: string;
        name?: string;
    };
}
export {};
