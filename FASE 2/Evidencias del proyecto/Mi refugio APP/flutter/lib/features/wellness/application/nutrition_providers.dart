import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/features/wellness/data/nutrition_repository.dart';
import 'package:mi_refugio_app/shared/models/nutrition_daily_summary.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository();
});

final nutritionSummaryProvider =
    FutureProvider.family<NutritionDailySummary?, DateTime>((ref, date) async {
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getDailySummary(date);
});
