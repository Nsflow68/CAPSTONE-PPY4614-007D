import { Injectable } from '@nestjs/common';
import { MindfulnessSessionDto } from './dto/mindfulness-session.dto';
import { PaginationDto } from '../common/dto/pagination.dto';

@Injectable()
export class MindfulnessService {
  private readonly sessions: MindfulnessSessionDto[] = [
    {
      id: 'breath-01',
      title: 'Respiración consciente (5 min)',
      durationMinutes: 5,
      level: 'beginner',
      tags: ['ansiedad', 'estres'],
      mediaUrl: 'https://cdn.mi-refugio.com/audio/breathing-5m.mp3'
    },
    {
      id: 'body-scan-10',
      title: 'Body scan relajante',
      durationMinutes: 10,
      level: 'intermediate',
      tags: ['relajacion', 'descanso'],
      mediaUrl: 'https://cdn.mi-refugio.com/audio/body-scan-10m.mp3'
    },
    {
      id: 'gratitude-07',
      title: 'Diario de gratitud guiado',
      durationMinutes: 7,
      level: 'beginner',
      tags: ['gratitud', 'estado-de-animo'],
      mediaUrl: 'https://cdn.mi-refugio.com/audio/gratitude-7m.mp3'
    }
  ];

  listSessions({ page = 1, limit = 10 }: PaginationDto) {
    const offset = (page - 1) * limit;
    const items = this.sessions.slice(offset, offset + limit);
    return {
      page,
      limit,
      total: this.sessions.length,
      items
    };
  }

  getHighlights() {
    return {
      featured: this.sessions[0],
      quickWins: this.sessions.filter((session) => session.durationMinutes <= 7)
    };
  }
}
