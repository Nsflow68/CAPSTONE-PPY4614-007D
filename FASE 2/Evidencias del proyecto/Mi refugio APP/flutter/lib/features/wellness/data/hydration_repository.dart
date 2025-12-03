import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_refugio_app/core/services/api_service.dart';
import 'package:mi_refugio_app/shared/models/hydration_daily_intake.dart';

final hydrationRepositoryProvider = Provider<HydrationRepository>((ref) {
  return HydrationRepository();
});

class HydrationRepository {
  final ApiService _apiService = ApiService.instance;

  Future<List<HydrationDailyIntake>> fetchWeeklyIntake() async {
    try {
      final response = await _apiService.getRaw('/hydration/weekly');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          final date = DateTime.parse(item['date']);
          return HydrationDailyIntake(
            date: date,
            dateLabel: DateFormat('EEE', 'es').format(date),
            totalMl: (item['totalMl'] as num).toDouble(),
            goalMl: (item['goalMl'] as num).toDouble(),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching hydration: $e');
      return [];
    }
  }

  Future<void> registerIntake({required DateTime date, required int ml}) async {
    try {
      await _apiService.postRaw(
        '/hydration',
        body: jsonEncode({
          'date': DateFormat('yyyy-MM-dd').format(date),
          'amountMl': ml,
        }),
      );
    } catch (e) {
      debugPrint('Error registering intake: $e');
      rethrow;
    }
  }
}
