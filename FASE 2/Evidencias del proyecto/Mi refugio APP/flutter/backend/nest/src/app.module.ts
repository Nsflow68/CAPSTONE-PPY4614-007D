import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import appConfig from './config/app.config';
import { HealthModule } from './health/health.module';
import { AuthModule } from './auth/auth.module';
import { MindfulnessModule } from './mindfulness/mindfulness.module';
import { HydrationModule } from './hydration/hydration.module';
import { DiaryModule } from './diary/diary.module';
import { ResourcesModule } from './resources/resources.module';
import { RefugesModule } from './refuges/refuges.module';
import { AdoptionsModule } from './adoptions/adoptions.module';
import { PrismaModule } from './database/prisma.module';
import { CommonModule } from './common/common.module';
import { ChatModule } from './chat/chat.module';

@Module({
  imports: [
    CommonModule,
    PrismaModule,
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig],
    }),
    HealthModule,
    AuthModule,
    MindfulnessModule,
    HydrationModule,
    DiaryModule,
    ResourcesModule,
    RefugesModule,
    AdoptionsModule,
    ChatModule,
  ],
})
export class AppModule {}
