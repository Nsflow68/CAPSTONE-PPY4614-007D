import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reward_state.dart';

final rewardProvider = StateNotifierProvider<RewardNotifier, RewardState>((
  ref,
) {
  return RewardNotifier()..loadRewards();
});

class RewardNotifier extends StateNotifier<RewardState> {
  RewardNotifier() : super(const RewardInitial());

  RewardSummary _summary = const RewardSummary(items: [], balance: 0);

  Future<void> loadRewards() async {
    state = const RewardLoading();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _summary = RewardSummary(
      balance: 240,
      items: const [
        Reward(
          id: 'gratitude',
          title: 'Diario 3 dias seguidos',
          description:
              'Suma tus reflexiones durante 3 dias y recibe puntos extra.',
          points: 75,
          active: true,
        ),
        Reward(
          id: 'hydration',
          title: 'Hidratacion consistente',
          description: 'Mantente sobre el 70% de tu meta de agua 4 dias.',
          points: 45,
        ),
        Reward(
          id: 'mindfulness',
          title: 'Mindfulness semanal',
          description: 'Completa 3 sesiones guiadas en la semana.',
          points: 60,
        ),
      ],
    );
    state = RewardLoaded(_summary);
  }

  Future<void> awardPoints(int amount) async {
    if (amount <= 0) return;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final updated = _summary.copyWith(balance: _summary.balance + amount);
    _summary = updated;
    state = RewardLoaded(updated);
  }
}
