import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HydrationDailyIntake {
  HydrationDailyIntake({
    DateTime? date,
    String? dateLabel,
    double? totalMl,
    this.goalMl,
  }) : date = DateUtils.dateOnly(date ?? DateTime.now()),
       createdAt = date ?? DateTime.now(),
       dateLabel =
           dateLabel ?? DateFormat('EEE', 'es').format(date ?? DateTime.now()),
       totalMl = totalMl ?? 0;

  final DateTime date;
  final DateTime createdAt;
  final String dateLabel;
  final double totalMl;
  final double? goalMl;
  double get totalLiters => totalMl / 1000;
  double get progress =>
      goalMl == null || goalMl == 0 ? 0 : (totalMl / goalMl!).clamp(0, 1);

  HydrationDailyIntake copyWith({
    DateTime? date,
    String? dateLabel,
    double? totalMl,
    double? goalMl,
  }) {
    return HydrationDailyIntake(
      date: date ?? this.date,
      dateLabel: dateLabel ?? this.dateLabel,
      totalMl: totalMl ?? this.totalMl,
      goalMl: goalMl ?? this.goalMl,
    );
  }
}
