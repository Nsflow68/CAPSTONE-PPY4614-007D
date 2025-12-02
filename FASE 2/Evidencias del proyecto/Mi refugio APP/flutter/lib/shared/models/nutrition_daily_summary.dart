import 'package:mi_refugio_app/shared/models/nutrition_log.dart';

class NutritionDailySummary {
  final DateTime date;
  final NutritionTotals totals;
  final List<NutritionLog> logs;

  NutritionDailySummary({
    required this.date,
    required this.totals,
    required this.logs,
  });

  factory NutritionDailySummary.fromJson(Map<String, dynamic> json) {
    return NutritionDailySummary(
      date: DateTime.parse(json['date']),
      totals: NutritionTotals.fromJson(json['totals']),
      logs: (json['logs'] as List)
          .map((log) => NutritionLog.fromJson(log))
          .toList(),
    );
  }
}

class NutritionTotals {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  NutritionTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionTotals.fromJson(Map<String, dynamic> json) {
    return NutritionTotals(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }
}
