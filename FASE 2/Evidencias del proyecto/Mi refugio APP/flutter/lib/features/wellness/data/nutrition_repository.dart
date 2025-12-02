import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_refugio_app/core/services/api_service.dart';
import 'package:mi_refugio_app/shared/models/nutrition_daily_summary.dart';
import 'package:mi_refugio_app/shared/models/nutrition_log.dart';

class NutritionRepository {
  final ApiService _apiService = ApiService.instance;

  Future<NutritionDailySummary?> getDailySummary(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await _apiService.getRaw('/nutrition/daily', query: {'date': dateStr});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NutritionDailySummary.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching nutrition summary: $e');
      return null;
    }
  }

  Future<void> logMeal(NutritionLog log) async {
    try {
      await _apiService.postRaw(
        '/nutrition',
        body: jsonEncode(log.toJson()),
      );
    } catch (e) {
      debugPrint('Error logging meal: $e');
      rethrow;
    }
  }
}
