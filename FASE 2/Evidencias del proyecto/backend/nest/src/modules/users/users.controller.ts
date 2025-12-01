import { Controller, Get, Post, Body, ConflictException } from '@nestjs/common';
import { UsersService } from './users.service';
import * as pbkdf2 from 'pbkdf2';
import * as crypto from 'crypto';

@Controller('users')
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    @Post()
    async create(@Body() createUserDto: any) {
        // Check if user exists
        const existing = await this.usersService.findOneByUsername(createUserDto.username);
        if (existing) {
            throw new ConflictException({
                success: false,
                message: 'El nombre de usuario o correo ya existe.',
            });
        }

        // Hash password (Django style for compatibility)
        const salt = crypto.randomBytes(12).toString('base64');
        const iterations = 100000;
        const derivedKey = pbkdf2.pbkdf2Sync(createUserDto.password, salt, iterations, 32, 'sha256');
        const hash = derivedKey.toString('base64');
        const passwordHash = `pbkdf2_sha256$${iterations}$${salt}$${hash}`;

        const user = await this.usersService.create({
            username: createUserDto.username,
            email: createUserDto.email || createUserDto.username,
            password: passwordHash,
            fullName: createUserDto.full_name,
            role: createUserDto.role || 'user',
            isActive: true,
        });

        return {
            id: user.id,
            username: user.username,
            full_name: user.fullName,
            role: user.role,
            status: 'Activo',
        };
    }

    @Get()
    findAll() {
        return this.usersService.findAll();
    }
}
