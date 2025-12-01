import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { PasswordUtil } from '../../common/utils/password.util';

@Injectable()
export class AuthService {
    constructor(private usersService: UsersService) { }

    async validateUser(username: string, pass: string): Promise<any> {
        const user = await this.usersService.findOneByUsername(username);
        if (user && PasswordUtil.verifyDjangoPassword(pass, user.password)) {
            const { password, ...result } = user;
            return result;
        }
        return null;
    }

    async login(user: any) {
        // Return exactly what the Flutter app expects
        return {
            success: true,
            user: {
                id: user.id,
                username: user.username,
                full_name: user.fullName,
                role: user.role,
            },
        };
    }
}
