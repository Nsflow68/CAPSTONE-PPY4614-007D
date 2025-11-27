import { PartialType } from '@nestjs/mapped-types';
import { CreateDiaryEntryDto } from './create-diary-entry.dto';

export class UpdateDiaryEntryDto extends PartialType(CreateDiaryEntryDto) {}
