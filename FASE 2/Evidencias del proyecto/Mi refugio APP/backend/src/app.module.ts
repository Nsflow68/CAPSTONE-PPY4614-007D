import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { HealthModule } from './core/health/health.module';
import { DiaryModule } from './features/diary/diary.module';
import { ResourcesModule } from './features/resources/resources.module';
import { ChatbotModule } from './features/chatbot/chatbot.module';
import { AuthModule } from './features/auth/auth.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    HealthModule,
    AuthModule,
    DiaryModule,
    ResourcesModule,
    ChatbotModule,
  ],
})
export class AppModule {}
