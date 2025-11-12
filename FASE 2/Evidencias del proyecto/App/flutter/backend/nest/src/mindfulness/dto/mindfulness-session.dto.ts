export class MindfulnessSessionDto {
  id: string;
  title: string;
  durationMinutes: number;
  level: 'beginner' | 'intermediate' | 'advanced';
  tags: string[];
  mediaUrl: string;
}
