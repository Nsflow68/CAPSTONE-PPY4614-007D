import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);
  private healthy = false;

  async onModuleInit() {
    try {
      await this.$connect();
      this.healthy = true;
      this.logger.log('Conexion a PostgreSQL establecida via Prisma');
    } catch (error) {
      this.healthy = false;
      this.logger.warn(
        `No fue posible conectar a la base de datos (usando modo fallback). Detalle: ${error}`,
      );
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }

  get isHealthy() {
    return this.healthy;
  }
}
