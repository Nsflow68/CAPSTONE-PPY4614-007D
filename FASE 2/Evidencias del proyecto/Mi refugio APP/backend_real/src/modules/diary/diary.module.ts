import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DiaryController } from './diary.controller';
import { DiaryService } from './diary.service';
import { DiaryEntry } from './entities/diary-entry.entity';

@Module({
    imports: [TypeOrmModule.forFeature([DiaryEntry])],
    controllers: [DiaryController],
    providers: [DiaryService],
    exports: [DiaryService],
})
export class DiaryModule { }
