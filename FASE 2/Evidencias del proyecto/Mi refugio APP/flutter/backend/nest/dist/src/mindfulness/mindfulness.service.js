"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MindfulnessService = void 0;
const common_1 = require("@nestjs/common");
const mindfulness_reference_json_1 = __importDefault(require("./mindfulness.reference.json"));
let MindfulnessService = class MindfulnessService {
    constructor() {
        this.dataset = mindfulness_reference_json_1.default;
        this.sessions = this.dataset.items;
    }
    listSessions({ page = 1, limit = 10 }) {
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
};
exports.MindfulnessService = MindfulnessService;
exports.MindfulnessService = MindfulnessService = __decorate([
    (0, common_1.Injectable)()
], MindfulnessService);
//# sourceMappingURL=mindfulness.service.js.map