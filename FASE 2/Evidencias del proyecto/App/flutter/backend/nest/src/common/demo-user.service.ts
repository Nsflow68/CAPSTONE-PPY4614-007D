import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import { User } from '@prisma/client';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class DemoUserService {
  private cachedUser?: User;

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {}

  async getUser(): Promise<User> {
    if (!this.prisma.isHealthy) {
      return {
        id: 'demo-user',
        email: this.demoEmail,
        name: 'Invitado Mi Refugio',
        avatarUrl: null,
        createdAt: new Date(),
        updatedAt: new Date(),
        password: 'demo',
        role: 'member',
      };
    }

    if (this.cachedUser) {
      return this.cachedUser;
    }

    const hashed = await bcrypt.hash('Temporal123!', 10);
    const user = await this.prisma.user.upsert({
      where: { email: this.demoEmail },
      update: { name: 'Invitado Mi Refugio' },
      create: {
        email: this.demoEmail,
        name: 'Invitado Mi Refugio',
        password: hashed,
        avatarUrl: null,
        role: 'member',
      },
    });

    this.cachedUser = user;
    return user;
  }

  async getUserId(): Promise<string> {
    const user = await this.getUser();
    return user.id;
  }

  private get demoEmail() {
    return this.configService.get<string>('demoUserEmail') ?? 'invitado@mirefugio.cl';
  }
}
