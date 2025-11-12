class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.moodText,
    required this.score,
    required this.date,
    required this.createdAt,
    this.emotions = const [],
    this.tags = const [],
  });

  final String id;
  final String title;
  final String content;
  final String mood;
  final String moodText;
  final int score;
  final DateTime date;
  final DateTime createdAt;
  final List<String> emotions;
  final List<String> tags;

  DiaryEntry copyWith({
    String? id,
    String? title,
    String? content,
    String? mood,
    String? moodText,
    int? score,
    DateTime? date,
    DateTime? createdAt,
    List<String>? emotions,
    List<String>? tags,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      moodText: moodText ?? this.moodText,
      score: score ?? this.score,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      emotions: emotions ?? this.emotions,
      tags: tags ?? this.tags,
    );
  }
}
