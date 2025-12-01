import { MindfulnessService } from './mindfulness.service';
import { PaginationDto } from '../common/dto/pagination.dto';
export declare class MindfulnessController {
    private readonly mindfulnessService;
    constructor(mindfulnessService: MindfulnessService);
    getSessions(pagination: PaginationDto): {
        page: number;
        limit: number;
        total: number;
        items: import("./dto/mindfulness-session.dto").MindfulnessSessionDto[];
    };
    getHighlights(): {
        featured: import("./dto/mindfulness-session.dto").MindfulnessSessionDto;
        quickWins: import("./dto/mindfulness-session.dto").MindfulnessSessionDto[];
    };
}
