import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class HealthService {
  constructor(
    private readonly httpService: HttpService,
    private readonly configService: ConfigService
  ) {}

  async check() {
    const fastApiUrl = this.configService.get<string>('fastapiBaseUrl');
    let fastapiAvailable = false;

    try {
      const response = await this.httpService.axiosRef.get(`${fastApiUrl}/health`, {
        timeout: 2000
      });
      fastapiAvailable = response.status < 400;
    } catch {
      fastapiAvailable = false;
    }

    return {
      service: 'mi-refugio-nest',
      env: this.configService.get<string>('env'),
      timestamp: new Date().toISOString(),
      dependencies: {
        fastapi: fastapiAvailable
      }
    };
  }
}
