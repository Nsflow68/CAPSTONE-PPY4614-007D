import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/features/wellness/data/hydration_repository.dart';
import 'package:mi_refugio_app/shared/models/hydration_daily_intake.dart';

final hydrationSummaryProvider =
    FutureProvider<List<HydrationDailyIntake>>((ref) async {
  final repo = ref.watch(hydrationRepositoryProvider);
  return repo.fetchWeeklyIntake();
});
