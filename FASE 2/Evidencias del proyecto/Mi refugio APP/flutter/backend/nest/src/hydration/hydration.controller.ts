import { Body, Controller, Get, Post } from '@nestjs/common';
import { HydrationService } from './hydration.service';
import { RegisterIntakeDto } from './dto/register-intake.dto';

@Controller('hydration')
export class HydrationController {
  constructor(private readonly hydrationService: HydrationService) {}

  @Get('weekly')
  getWeeklyIntake() {
    return this.hydrationService.listWeeklyIntake();
  }

  @Get('today')
  getToday() {
    return this.hydrationService.getTodayIntake();
  }

  @Post('register')
  register(@Body() dto: RegisterIntakeDto) {
    return this.hydrationService.registerIntake(dto);
  }
}
