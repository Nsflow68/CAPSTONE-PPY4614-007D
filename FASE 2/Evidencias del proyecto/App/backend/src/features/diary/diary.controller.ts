import { Body, Controller, Delete, Get, Param, Patch, Post } from '@nestjs/common';
import { DiaryService } from './diary.service';
import { CreateDiaryEntryDto } from './dto/create-diary-entry.dto';
import { UpdateDiaryEntryDto } from './dto/update-diary-entry.dto';

@Controller('diary')
export class DiaryController {
  constructor(private readonly diaryService: DiaryService) {}

  // Nota: se utiliza un usuario mock mientras se integra JWT.
  private readonly mockUserId = '1';

  @Get()
  findAll() {
    return this.diaryService.findAll(this.mockUserId);
  }

  @Post()
  create(@Body() dto: CreateDiaryEntryDto) {
    return this.diaryService.create(this.mockUserId, dto);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateDiaryEntryDto) {
    return this.diaryService.update(this.mockUserId, id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.diaryService.remove(this.mockUserId, id);
  }
}
