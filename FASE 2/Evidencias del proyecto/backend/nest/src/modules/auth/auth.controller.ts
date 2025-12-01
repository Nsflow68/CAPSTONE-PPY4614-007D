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
        console.log('Login success:', user.username);
        return this.authService.login(user);
    }
}
