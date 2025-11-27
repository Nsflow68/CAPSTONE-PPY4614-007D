class MindfulnessSummary {
  const MindfulnessSummary({
    required this.completedSessions,
    required this.streakDays,
    required this.totalMinutes,
    this.byType = const {},
  });

  final int completedSessions;
  final int streakDays;
  final int totalMinutes;
  final Map<String, int> byType;

  MindfulnessSummary copyWith({
    int? completedSessions,
    int? streakDays,
    int? totalMinutes,
    Map<String, int>? byType,
  }) {
    return MindfulnessSummary(
      completedSessions: completedSessions ?? this.completedSessions,
      streakDays: streakDays ?? this.streakDays,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      byType: byType ?? this.byType,
    );
  }

  static const empty = MindfulnessSummary(
    completedSessions: 0,
    streakDays: 0,
    totalMinutes: 0,
  );
}
