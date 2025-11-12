import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { DiaryService } from './diary.service';
import { DiaryFilterDto } from './dto/diary-filter.dto';
import { CreateDiaryEntryDto } from './dto/create-diary-entry.dto';

@Controller('diary')
export class DiaryController {
  constructor(private readonly diaryService: DiaryService) {}

  @Get('entries')
  listEntries(@Query() filters: DiaryFilterDto) {
    return this.diaryService.listEntries(filters);
  }

  @Post('entries')
  createEntry(@Body() dto: CreateDiaryEntryDto) {
    return this.diaryService.createEntry(dto);
  }
}
