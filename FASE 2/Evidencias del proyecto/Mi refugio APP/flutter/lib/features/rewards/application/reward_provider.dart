import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/features/rewards/data/rewards_repository.dart';
import 'package:mi_refugio_app/shared/models/user_rewards.dart';

final rewardsRepositoryProvider = Provider<RewardsRepository>((ref) {
  return RewardsRepository();
});

final rewardProvider =
    StateNotifierProvider<RewardNotifier, AsyncValue<UserRewards>>((ref) {
  return RewardNotifier(ref.watch(rewardsRepositoryProvider));
});

class RewardNotifier extends StateNotifier<AsyncValue<UserRewards>> {
  final RewardsRepository _repository;

  RewardNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadRewards();
  }

  Future<void> loadRewards() async {
    try {
      state = const AsyncValue.loading();
      final rewards = await _repository.getRewards();
      if (rewards != null) {
        state = AsyncValue.data(rewards);
      } else {
        // If null (maybe first time), return empty/default
        state = AsyncValue.data(UserRewards(
          userId: '',
          points: 0,
          currentStreak: 0,
          unlockedMascots: [],
        ));
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> awardPoints(int points) async {
    try {
      await _repository.addPoints(points);
      
      // Refresh state to get new total points
      final currentRewards = await _repository.getRewards();
      if (currentRewards != null) {
        final newPoints = currentRewards.points;
        final unlocked = List<String>.from(currentRewards.unlockedMascots);
        bool changed = false;

        // Unlocking Logic
        if (newPoints >= 0 && !unlocked.contains('pose_1')) {
          unlocked.add('pose_1');
          changed = true;
        }
        if (newPoints >= 500 && !unlocked.contains('pose_2')) {
          unlocked.add('pose_2');
          changed = true;
        }
        if (newPoints >= 1000 && !unlocked.contains('pose_3')) {
          unlocked.add('pose_3');
          changed = true;
        }
        if (newPoints >= 2000 && !unlocked.contains('pose_4')) {
          unlocked.add('pose_4');
          changed = true;
        }

        if (changed) {
          await _repository.updateUnlockedMascots(unlocked);
          // Reload to reflect changes
          await loadRewards();
        } else {
          state = AsyncValue.data(currentRewards);
        }
      }
    } catch (e) {
      // Handle error silently or expose via state if needed
    }
  }
}
