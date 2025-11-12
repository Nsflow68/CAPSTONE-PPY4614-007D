export class DiaryEntryDto {
  id!: string;
  title!: string;
  content!: string;
  mood!: string;
  score!: number;
  moodText!: string;
  date!: string;
  createdAt!: string;
  emotions!: string[];
  tags!: string[];
}
