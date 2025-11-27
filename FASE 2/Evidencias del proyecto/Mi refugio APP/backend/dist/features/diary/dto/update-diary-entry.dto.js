"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateDiaryEntryDto = void 0;
const mapped_types_1 = require("@nestjs/mapped-types");
const create_diary_entry_dto_1 = require("./create-diary-entry.dto");
class UpdateDiaryEntryDto extends (0, mapped_types_1.PartialType)(create_diary_entry_dto_1.CreateDiaryEntryDto) {
}
exports.UpdateDiaryEntryDto = UpdateDiaryEntryDto;
//# sourceMappingURL=update-diary-entry.dto.js.map