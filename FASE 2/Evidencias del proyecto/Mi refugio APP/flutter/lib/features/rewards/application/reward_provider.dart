import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mi_refugio_app/core/services/storage_service.dart';

import 'reward_state.dart';

const _rewardStorageKey = StorageKeys.rewardSummary;
const _loadDelay = Duration(milliseconds: 350);
const _mutationDelay = Duration(milliseconds: 180);

final rewardProvider = StateNotifierProvider<RewardNotifier, RewardState>((ref) {
  return RewardNotifier(storage: const FlutterSecureStorage())..loadRewards();
});

class RewardNotifier extends StateNotifier<RewardState> {
  RewardNotifier({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(const RewardInitial());

  final FlutterSecureStorage _storage;
  RewardSummary _summary = const RewardSummary(items: [], balance: 0);

  Future<void> loadRewards() async {
    state = const RewardLoading();
    await Future<void>.delayed(_loadDelay);
    try {
      final raw = await _storage.read(key: _rewardStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _summary = RewardSummary.fromJson(data);
      } else {
        _summary = _defaultSummary();
        await _persistSummary();
      }
      _summary = _applyBadges(_summary);
      state = RewardLoaded(_summary);
    } catch (error) {
      state = RewardError('No pudimos cargar tus logros. Intenta nuevamente.');
    }
  }

  Future<void> awardPoints(int amount) async {
    if (amount <= 0) return;
    await Future<void>.delayed(_mutationDelay);
    final updated =
        _applyBadges(_summary.copyWith(balance: _summary.balance + amount));
    _summary = updated;
    await _persistSummary();
    state = RewardLoaded(updated);
  }

  Future<void> markRewardCompleted(String id) async {
    final current = _summary.items.firstWhere(
      (item) => item.id == id,
      orElse: () => const Reward(
        id: 'unknown',
        title: '',
        description: '',
        points: 0,
      ),
    );
    if (current.id == 'unknown') return;
    final updatedItems = _summary.items.map((reward) {
      if (reward.id != id) return reward;
      return reward.copyWith(active: true);
    }).toList();
    _summary = _summary.copyWith(items: updatedItems);
    await _persistSummary();
    state = RewardLoaded(_summary);
  }

  Future<void> resetRewards() async {
    _summary = _defaultSummary();
    await _persistSummary();
    state = RewardLoaded(_summary);
  }

  RewardSummary _defaultSummary() {
    return RewardSummary(
      balance: 240,
      items: const [
        Reward(
          id: 'gratitude',
          title: 'Diario 3 días seguidos',
          description:
              'Escribe tus reflexiones 3 días seguidos y recibe puntos extra.',
          points: 75,
        ),
        Reward(
          id: 'hydration',
          title: 'Hidratación consistente',
          description: 'Mantente sobre el 70% de tu meta de agua 4 días.',
          points: 45,
        ),
        Reward(
          id: 'mindfulness',
          title: 'Mindfulness semanal',
          description: 'Completa 3 sesiones guiadas en la semana.',
          points: 60,
        ),
        Reward(
          id: 'support',
          title: 'Compartir recursos',
          description:
              'Envía el directorio de ayuda a otra persona que lo necesite.',
          points: 30,
        ),
      ],
    );
  }

  RewardSummary _applyBadges(RewardSummary summary) {
    final updatedItems = summary.items
        .map(
          (reward) => reward.copyWith(
            active: summary.balance >= reward.points ? true : reward.active,
          ),
        )
        .toList();
    return summary.copyWith(items: updatedItems);
  }

  Future<void> _persistSummary() async {
    final payload = jsonEncode(_summary.toJson());
    await _storage.write(key: _rewardStorageKey, value: payload);
  }
}
