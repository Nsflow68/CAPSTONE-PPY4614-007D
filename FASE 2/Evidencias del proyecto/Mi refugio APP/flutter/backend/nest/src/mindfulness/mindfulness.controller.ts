import { Controller, Get, Query } from '@nestjs/common';
import { MindfulnessService } from './mindfulness.service';
import { PaginationDto } from '../common/dto/pagination.dto';

@Controller('mindfulness')
export class MindfulnessController {
  constructor(private readonly mindfulnessService: MindfulnessService) {}

  @Get('sessions')
  getSessions(@Query() pagination: PaginationDto) {
    return this.mindfulnessService.listSessions(pagination);
  }

  @Get('highlights')
  getHighlights() {
    return this.mindfulnessService.getHighlights();
  }
}
