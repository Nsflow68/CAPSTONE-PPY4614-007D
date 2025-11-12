import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import appConfig from './config/app.config';
import { HealthModule } from './health/health.module';
import { AuthModule } from './auth/auth.module';
import { MindfulnessModule } from './mindfulness/mindfulness.module';
import { HydrationModule } from './hydration/hydration.module';
import { DiaryModule } from './diary/diary.module';
import { ResourcesModule } from './resources/resources.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig]
    }),
    HealthModule,
    AuthModule,
    MindfulnessModule,
    HydrationModule,
    DiaryModule,
    ResourcesModule
  ]
})
export class AppModule {}
