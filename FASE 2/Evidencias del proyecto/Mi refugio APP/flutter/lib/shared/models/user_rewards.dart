class UserRewards {
  final String userId;
  final int points;
  final int currentStreak;
  final List<String> unlockedMascots;

  UserRewards({
    required this.userId,
    required this.points,
    required this.currentStreak,
    required this.unlockedMascots,
  });

  factory UserRewards.fromJson(Map<String, dynamic> json) {
    return UserRewards(
      userId: json['userId'],
      points: json['points'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      unlockedMascots: List<String>.from(json['unlockedMascots'] ?? []),
    );
  }
}
