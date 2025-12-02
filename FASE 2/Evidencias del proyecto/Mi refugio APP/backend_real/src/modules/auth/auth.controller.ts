import { Controller, Post, Body, UnauthorizedException, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
    constructor(private readonly authService: AuthService) { }

    @Post('login')
    @HttpCode(HttpStatus.OK)
    async login(@Body() signInDto: Record<string, any>) {
        console.log('Login attempt:', signInDto.username);
        const user = await this.authService.validateUser(signInDto.username, signInDto.password);
        if (!user) {
            console.log('Login failed: Invalid credentials');
            throw new UnauthorizedException({
                success: false,
                message: 'Credenciales inválidas',
            });
        }
        console.log('Login success:', user.email);
        return this.authService.login(user);
    }

    @Post('test')
    @HttpCode(HttpStatus.OK)
    async test() {
        console.log('[AuthController] Test endpoint called');
        return { success: true, message: 'Backend is working!' };
    }

    @Post('google-login')
    @HttpCode(HttpStatus.OK)
    async googleLogin(@Body() body: { token: string }) {
        console.log('Google login attempt');
        return this.authService.loginWithGoogle(body.token);
    }

    @Post('register')
    @HttpCode(HttpStatus.CREATED)
    async register(@Body() registerDto: {
        email: string;
        username: string;
        name: string;
        password: string;
        rut: string;
        birthDate?: string;
        gender?: string;
    }) {
        console.log('Register attempt:', registerDto.email);

        const user = await this.authService.register(registerDto);
        return {
            success: true,
            message: 'Usuario registrado exitosamente',
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
            },
        };
    }
}
