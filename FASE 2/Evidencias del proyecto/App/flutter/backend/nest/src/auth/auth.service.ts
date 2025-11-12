import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { LoginDto } from './dto/login.dto';
import { SignupDto } from './dto/signup.dto';

@Injectable()
export class AuthService {
  login(payload: LoginDto) {
    // Mock response; en producción se reemplazará por lógica real (Prisma + JWT)
    return {
      accessToken: this.generateToken(payload.email),
      user: {
        id: randomUUID(),
        email: payload.email,
        name: 'Usuario Mi Refugio'
      }
    };
  }

  signup(payload: SignupDto) {
    return {
      message: 'Usuario registrado temporalmente en modo stub',
      user: {
        id: randomUUID(),
        email: payload.email,
        name: payload.name
      },
      accessToken: this.generateToken(payload.email)
    };
  }

  private generateToken(subject: string) {
    const fakeToken = Buffer.from(`${subject}:${Date.now()}`).toString('base64url');
    return `mock.${fakeToken}.token`;
  }
}
