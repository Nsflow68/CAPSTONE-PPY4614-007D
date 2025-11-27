import { MindfulnessSessionDto } from './dto/mindfulness-session.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
export declare class MindfulnessService {
    private readonly dataset;
    private readonly sessions;
    listSessions({ page, limit }: PaginationDto): {
        page: number;
        limit: number;
        total: number;
        items: MindfulnessSessionDto[];
    };
    getHighlights(): {
        featured: MindfulnessSessionDto;
        quickWins: MindfulnessSessionDto[];
    };
}
