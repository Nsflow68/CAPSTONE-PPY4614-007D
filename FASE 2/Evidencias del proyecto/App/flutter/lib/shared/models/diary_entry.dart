class DiaryEntry {
  DiaryEntry({
    required this.id,
    required this.title,
    required this.mood,
    required this.createdAt,
    required this.body,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String mood;
  final DateTime createdAt;
  final String body;
  final List<String> tags;
}
