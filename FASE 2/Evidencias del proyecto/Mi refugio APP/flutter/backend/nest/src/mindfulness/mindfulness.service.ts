import { Injectable } from '@nestjs/common';
import { MindfulnessSessionDto } from './dto/mindfulness-session.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import mindfulnessReference from './mindfulness.reference.json';

@Injectable()
export class MindfulnessService {
  private readonly dataset = mindfulnessReference as { items: MindfulnessSessionDto[] };
  private readonly sessions: MindfulnessSessionDto[] = this.dataset.items;

  listSessions({ page = 1, limit = 10 }: PaginationDto) {
    const offset = (page - 1) * limit;
    const items = this.sessions.slice(offset, offset + limit);
    return {
      page,
      limit,
      total: this.sessions.length,
      items,
    };
  }

  getHighlights() {
    return {
      featured: this.sessions[0],
      quickWins: this.sessions.filter((session) => session.durationMinutes <= 7),
    };
  }
}
