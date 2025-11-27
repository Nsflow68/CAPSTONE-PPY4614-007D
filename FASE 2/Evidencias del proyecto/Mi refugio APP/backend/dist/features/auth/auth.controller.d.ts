import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    login(dto: LoginDto): {
        accessToken: string;
        user: {
            id: string;
            email: string;
            name: string;
            role: string;
        };
    };
    guest(): {
        accessToken: string;
        user: {
            id: string;
            email: string;
            name: string;
            role: string;
        };
    };
}
