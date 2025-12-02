import { Controller, Get, Post, Body, ConflictException } from '@nestjs/common';
import { UsersService } from './users.service';
import * as pbkdf2 from 'pbkdf2';
import * as crypto from 'crypto';

@Controller('users')
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    @Post()
    async create(@Body() createUserDto: any) {
        // Check if user exists (by username OR email)
        const existingUsername = await this.usersService.findOneByUsername(createUserDto.username);
        const existingEmail = await this.usersService.findOneByUsername(createUserDto.email);

        if (existingUsername || existingEmail) {
            throw new ConflictException({
                success: false,
                message: 'El nombre de usuario o correo ya existe.',
            });
        }

        // Hash password (Django style for compatibility)
        const salt = crypto.randomBytes(12).toString('base64');
        const iterations = 1000;
        const derivedKey = pbkdf2.pbkdf2Sync(createUserDto.password, salt, iterations, 32, 'sha256');
        const hash = derivedKey.toString('base64');
        const passwordHash = `pbkdf2_sha256$${iterations}$${salt}$${hash}`;

        const user = await this.usersService.create({
            id: crypto.randomUUID(),
            email: createUserDto.email || createUserDto.username,
            username: createUserDto.username || createUserDto.email, // Fallback to email if username missing
            password: passwordHash,
            name: createUserDto.full_name,
            role: createUserDto.role || 'user',
            createdAt: new Date(),
            updatedAt: new Date(),
        });

        return {
            id: user.id,
            username: user.email,  // Return email as username for compatibility
            full_name: user.name,
            role: user.role,
            status: 'Activo',
        };
    }

    @Get()
    findAll() {
        return this.usersService.findAll();
    }
}
