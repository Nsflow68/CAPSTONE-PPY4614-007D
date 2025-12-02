import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { RutValidator } from '../../common/utils/rut-validator.util';
import { BadRequestException } from '@nestjs/common';

@Injectable()
export class UsersService {
    constructor(
        @InjectRepository(User)
        private usersRepository: Repository<User>,
    ) { }

    async findOneByUsername(username: string): Promise<User | null> {
        // We need to select password explicitly because it's hidden by default
        // Also select all other fields to ensure they're available
        return this.usersRepository.createQueryBuilder('user')
            .select(['user.id', 'user.email', 'user.name', 'user.role', 'user.rut', 'user.birthDate', 'user.gender', 'user.createdAt', 'user.updatedAt'])
            .addSelect('user.password')
            .where('user.username = :username OR user.email = :username', { username })
            .getOne();
    }

    async findOneByEmail(email: string): Promise<User | null> {
        return this.usersRepository.findOne({ where: { email } });
    }

    async create(userData: Partial<User>): Promise<User> {
        console.log('[UsersService] Creating user with data:', JSON.stringify(userData, null, 2));

        // Validar RUT si está presente
        if (userData.rut) {
            console.log('[UsersService] Validating RUT:', userData.rut);
            const cleanRut = RutValidator.clean(userData.rut);
            console.log('[UsersService] Cleaned RUT:', cleanRut);

            if (!RutValidator.validate(cleanRut)) {
                console.log('[UsersService] RUT validation failed');
                throw new BadRequestException('RUT inválido');
            }
            console.log('[UsersService] RUT validation passed');

            // Verificar que el RUT no esté en uso
            console.log('[UsersService] Checking if RUT exists in database');
            const existingUser = await this.usersRepository.findOne({ where: { rut: cleanRut } });
            if (existingUser) {
                console.log('[UsersService] RUT already exists');
                throw new BadRequestException('El RUT ya está registrado');
            }
            console.log('[UsersService] RUT is available');

            userData.rut = cleanRut;
        }

        console.log('[UsersService] Creating user entity');
        const newUser = this.usersRepository.create(userData);
        console.log('[UsersService] User entity created:', JSON.stringify(newUser, null, 2));

        console.log('[UsersService] Saving user to database');
        try {
            const savedUser = await this.usersRepository.save(newUser);
            console.log('[UsersService] User saved successfully:', savedUser.id);
            return savedUser;
        } catch (error) {
            console.error('[UsersService] Error saving user:', error);
            throw error;
        }
    }

    async findAll(): Promise<User[]> {
        return this.usersRepository.find();
    }
}
