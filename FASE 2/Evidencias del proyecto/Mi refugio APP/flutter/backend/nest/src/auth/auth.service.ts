import { BadRequestException, Injectable, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcryptjs';
import { JwtService } from '@nestjs/jwt';
import { randomUUID } from 'crypto';
import { PrismaService } from '../database/prisma.service';
import { LoginDto, AuthClient } from './dto/login.dto';
import { SignupDto } from './dto/signup.dto';

type UserRole = 'member' | 'therapist' | 'admin';

@Injectable()
export class AuthService {
  private readonly fallbackUser = {
    id: 'demo-user',
    email: 'demo@mirefugio.cl',
    name: 'Usuario Mi Refugio',
    role: 'member' as UserRole,
  };
  private readonly defaultClient: AuthClient = 'mobile';
  private readonly defaultRole: UserRole = 'member';
  private readonly clientAccessMatrix: Record<AuthClient, readonly UserRole[]> = {
    mobile: ['member', 'admin'],
    web: ['member', 'admin'],
    desktop: ['therapist', 'admin'],
  };
  private readonly knownRoles: readonly UserRole[] = ['member', 'therapist', 'admin'];

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  async login(payload: LoginDto) {
    const client = this.normalizeClient(payload.client);
    if (this.prisma.isHealthy) {
      const user = await this.prisma.user.findUnique({
        where: { email: payload.email },
      });

      if (!user) {
        throw new UnauthorizedException('invalid_credentials');
      }

      const passwordOk = await bcrypt.compare(payload.password, user.password);
      if (!passwordOk) {
        throw new UnauthorizedException('invalid_credentials');
      }

      const userRole = this.normalizeRole(user.role as UserRole | null);
      this.ensureClientAccess(userRole, client);

      return this.buildAuthPayload(user.id, user.email, user.name, userRole, client);
    }

    this.ensureClientAccess(this.fallbackUser.role, client);
    return this.buildAuthPayload(
      this.fallbackUser.id,
      payload.email,
      this.fallbackUser.name,
      this.fallbackUser.role,
      client,
    );
  }

  async signup(payload: SignupDto) {
    const client = this.normalizeClient(payload.client);
    if (this.prisma.isHealthy) {
      const exists = await this.prisma.user.findUnique({
        where: { email: payload.email },
      });

      if (exists) {
        throw new BadRequestException('email_already_registered');
      }

      const hashed = await bcrypt.hash(payload.password, 10);
      const user = await this.prisma.user.create({
        data: {
          email: payload.email,
          name: payload.name,
          password: hashed,
          role: this.defaultRole,
          avatarUrl: null,
        },
      });

      return this.buildAuthPayload(user.id, user.email, user.name, this.defaultRole, client);
    }

    this.ensureClientAccess(this.defaultRole, client);
    return this.buildAuthPayload(
      randomUUID(),
      payload.email,
      payload.name,
      this.defaultRole,
      client,
    );
  }

  private buildAuthPayload(
    id: string,
    email: string,
    name: string,
    role: UserRole,
    client: AuthClient,
  ) {
    return {
      accessToken: this.jwt.sign({ sub: id, email, role, client }),
      client,
      user: { id, email, name, role },
    };
  }

  private normalizeClient(client?: AuthClient): AuthClient {
    if (!client) {
      return this.defaultClient;
    }
    return this.clientAccessMatrix[client] ? client : this.defaultClient;
  }

  private normalizeRole(role?: UserRole | null): UserRole {
    if (!role) {
      return this.defaultRole;
    }
    return this.knownRoles.includes(role) ? role : this.defaultRole;
  }

  private ensureClientAccess(role: UserRole, client: AuthClient) {
    const allowedRoles = this.clientAccessMatrix[client];
    if (!allowedRoles.includes(role)) {
      throw new UnauthorizedException('role_not_allowed_for_client');
    }
  }
}
