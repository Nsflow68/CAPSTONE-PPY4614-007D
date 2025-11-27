class MindfulnessSession {
  const MindfulnessSession({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.focus,
    this.description = '',
    this.source = 'Mi Refugio',
    this.mediaUrl,
    this.resourceUrl,
  });

  final String id;
  final String title;
  final int durationMinutes;
  final String focus;
  final String description;
  final String source;
  final String? mediaUrl;
  final String? resourceUrl;

  String get duration => '$durationMinutes min';
}
