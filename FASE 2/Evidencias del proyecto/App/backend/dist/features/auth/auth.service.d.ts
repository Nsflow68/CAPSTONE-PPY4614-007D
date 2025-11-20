import { LoginDto } from './dto/login.dto';
export declare class AuthService {
    private readonly mockUsers;
    login(dto: LoginDto): {
        accessToken: string;
        user: {
            id: string;
            email: string;
            name: string;
            role: string;
        };
    };
    guestAccess(): {
        accessToken: string;
        user: {
            id: string;
            email: string;
            name: string;
            role: string;
        };
    };
}
