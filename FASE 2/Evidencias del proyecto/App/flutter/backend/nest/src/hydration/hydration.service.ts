import { Injectable, Logger } from '@nestjs/common';
import { HydrationDailyIntakeDto } from './dto/hydration-intake.dto';
import { RegisterIntakeDto } from './dto/register-intake.dto';

@Injectable()
export class HydrationService {
  private readonly logger = new Logger(HydrationService.name);

  private readonly weeklyIntake: HydrationDailyIntakeDto[] = (() => {
    const now = new Date();
    return Array.from({ length: 7 }).map((_, idx) => {
      const date = new Date(now);
      date.setDate(now.getDate() - (6 - idx));
      const totalMl = 1400 + idx * 120;
      const goalMl = 2000;
      return {
        date: date.toISOString().substring(0, 10),
        totalMl,
        goalMl,
        percentage: Number((totalMl / goalMl).toFixed(2))
      };
    });
  })();

  listWeeklyIntake() {
    return {
      items: this.weeklyIntake,
      averageMl:
          this.weeklyIntake.reduce((acc, item) => acc + item.totalMl, 0) /
          this.weeklyIntake.length
    };
  }

  getTodayIntake() {
    const today = new Date().toISOString().substring(0, 10);
    return (
      this.weeklyIntake.find((item) => item.date === today) ??
      this.weeklyIntake[this.weeklyIntake.length - 1]
    );
  }

  registerIntake(dto: RegisterIntakeDto) {
    const dateKey =
      dto.date ?? new Date().toISOString().substring(0, 10);
    const record =
      this.weeklyIntake.find((item) => item.date === dateKey) ??
      this.createRecord(dateKey);

    record.totalMl += dto.amountMl;
    record.percentage = Number((record.totalMl / record.goalMl).toFixed(2));
    this.logger.log(
      `Registrados ${dto.amountMl} ml para ${dateKey} (total ${record.totalMl} ml)`
    );

    return { message: 'intake_registered', record };
  }

  private createRecord(date: string) {
    const record: HydrationDailyIntakeDto = {
      date,
      totalMl: 0,
      goalMl: 2000,
      percentage: 0
    };
    this.weeklyIntake.push(record);
    return record;
  }
}
