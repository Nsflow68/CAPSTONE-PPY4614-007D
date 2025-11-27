import { Injectable } from '@nestjs/common';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  private readonly mockUsers = [
    {
      id: '1',
      email: 'mateo.flores@mirefugio.cl',
      name: 'Mateo Flores',
      role: 'Ciudadano',
    },
  ];

  login(dto: LoginDto) {
    const user =
      this.mockUsers.find((u) => u.email.toLowerCase() === dto.email.toLowerCase()) ??
      this.mockUsers[0];
    return {
      accessToken: 'mock-jwt-token',
      user,
    };
  }

  guestAccess() {
    return {
      accessToken: 'guest-token',
      user: {
        id: 'guest',
        email: 'invitado@mirefugio.cl',
        name: 'Invitado',
        role: 'Invitado',
      },
    };
  }
}
