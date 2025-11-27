import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_refugio_app/shared/models/hydration_daily_intake.dart';

final hydrationRepositoryProvider = Provider<HydrationRepository>((ref) {
  return HydrationRepository();
});

class HydrationRepository {
  HydrationRepository() {
    final now = DateTime.now();
    for (var i = 0; i < 7; i++) {
      final date = DateUtils.dateOnly(now.subtract(Duration(days: 6 - i)));
      _entries.add(
        HydrationDailyIntake(
          date: date,
          dateLabel: DateFormat('EEE', 'es').format(date),
          totalMl: 1400 + (i * 150),
          goalMl: 2000,
        ),
      );
    }
  }

  final List<HydrationDailyIntake> _entries = [];

  Future<List<HydrationDailyIntake>> fetchWeeklyIntake() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_entries);
  }

  Future<void> registerIntake({required DateTime date, required int ml}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final target = _entries.indexWhere((item) => item.date == date);
    if (target == -1) {
      _entries.add(
        HydrationDailyIntake(
          date: date,
          dateLabel: DateFormat('EEE', 'es').format(date),
          totalMl: ml.toDouble(),
          goalMl: 2000,
        ),
      );
    } else {
      final current = _entries[target];
      _entries[target] = current.copyWith(totalMl: current.totalMl + ml);
    }
  }
}
