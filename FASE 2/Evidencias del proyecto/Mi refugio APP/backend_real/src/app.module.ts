import { Module, NestModule, MiddlewareConsumer } from '@nestjs/common';
import { LoggerMiddleware } from './logger.middleware';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { ChatbotModule } from './modules/chatbot/chatbot.module';
import { DiaryModule } from './modules/diary/diary.module';
import { HydrationModule } from './modules/hydration/hydration.module';
import { NutritionModule } from './modules/nutrition/nutrition.module';
import { RewardsModule } from './modules/rewards/rewards.module';
import { typeOrmConfig } from './config/typeorm.config';

@Module({
  imports: [
    TypeOrmModule.forRoot(typeOrmConfig),
    AuthModule,
    UsersModule,
    ChatbotModule,
    DiaryModule,
    HydrationModule,
    NutritionModule,
    RewardsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(LoggerMiddleware)
      .forRoutes('*');
  }
}
