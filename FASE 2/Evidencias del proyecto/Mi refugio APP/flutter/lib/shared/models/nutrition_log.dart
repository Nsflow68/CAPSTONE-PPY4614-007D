import 'package:intl/intl.dart';

class NutritionLog {
  final String? id;
  final DateTime date;
  final String mealType;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> foodItems;

  NutritionLog({
    this.id,
    required this.date,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.foodItems,
  });

  factory NutritionLog.fromJson(Map<String, dynamic> json) {
    return NutritionLog(
      id: json['id'],
      date: DateTime.parse(json['date']),
      mealType: json['mealType'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      foodItems: List<String>.from(json['foodItems'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': DateFormat('yyyy-MM-dd').format(date),
      'mealType': mealType,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'foodItems': foodItems,
    };
  }
}
