import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { randomUUID } from 'crypto';

@Injectable()
export class AuthService {
    constructor(private usersService: UsersService) { }

    async validateUser(username: string, pass: string): Promise<any> {
        console.log(`[AuthService] Validating user: ${username}`);
        const user = await this.usersService.findOneByUsername(username);

        if (!user) {
            console.log(`[AuthService] User not found: ${username}`);
            return null;
        }

        console.log(`[AuthService] User found: ${user.email} (ID: ${user.id})`);

        // Plain text password comparison
        const isValid = pass === user.password;
        console.log(`[AuthService] Password valid: ${isValid}`);

        if (isValid) {
            const { password, ...result } = user;
            return result;
        }
        return null;
    }

    async login(user: any) {
        return {
            success: true,
            user: {
                id: user.id,
                username: user.email,
                full_name: user.name,
                role: user.role,
            },
            token: Buffer.from(user.id).toString('base64'),
        };
    }

    async loginWithGoogle(token: string) {
        let email = '';
        let name = '';

        if (token.includes('@')) {
            email = token;
            name = token.split('@')[0];
        } else {
            email = 'google_user@mirefugio.cl';
            name = 'Google User';
        }

        let user = await this.usersService.findOneByEmail(email);

        if (!user) {
            user = await this.usersService.create({
                id: randomUUID(),
                email: email,
                name: name,
                password: 'google-login-no-password',
                role: 'user',
                rut: `GOOGLE-${Date.now()}`,
            });
        }

        return this.login(user);
    }

    async register(registerDto: {
        email: string;
        username: string;
        name: string;
        password: string;
        rut: string;
        birthDate?: string;
        gender?: string;
    }) {
        console.log('[AuthService] Register called with:', JSON.stringify(registerDto, null, 2));

        // Store password in plain text (no hashing)
        console.log('[AuthService] Preparing user data');
        const userData = {
            id: randomUUID(),
            email: registerDto.email,
            username: registerDto.username,
            name: registerDto.name,
            password: registerDto.password, // Plain text password
            rut: registerDto.rut,
            birthDate: registerDto.birthDate ? new Date(registerDto.birthDate) : undefined,
            gender: registerDto.gender,
            role: 'user',
        };

        console.log('[AuthService] User data prepared:', JSON.stringify(userData, null, 2));
        console.log('[AuthService] Calling usersService.create');

        try {
            const user = await this.usersService.create(userData);
            console.log('[AuthService] User created successfully:', user.id);
            return user;
        } catch (error) {
            console.error('[AuthService] Error creating user:', error);
            throw error;
        }
    }
}
