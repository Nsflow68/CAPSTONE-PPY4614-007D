import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Paleta principal inspirada en emociones calmantes + destellos de energía
  static const Color primary = Color(0xFF675BFF);
  static const Color secondary = Color(0xFFFF8FB7);
  static const Color tertiary = Color(0xFF37D2C5);
  static const Color accent = Color(0xFFFACF5A);

  static const Color background = Color(0xFFF6F4FF);
  static const Color backgroundDark = Color(0xFF0F1020);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFECE8FF);
  static const Color textPrimary = Color(0xFF1F1A3D);
  static const Color textSecondary = Color(0xFF5A5376);

  /// Paleta para estados emocionales que se usan en carruseles y chips
  static const Color moodJoy = Color(0xFF47DA9F);
  static const Color moodCalm = Color(0xFF64C4FF);
  static const Color moodSad = Color(0xFFA694FF);
  static const Color moodAngry = Color(0xFFFF8F6C);
  static const Color moodHope = Color(0xFFFFC469);
  static const Color moodNeutral = Color(0xFFB5B1CB);

  static const Color success = Color(0xFF9ED9C5);
  static const Color warning = Color(0xFFFCE1B9);
  static const Color danger = Color(0xFFF8D4D8);

  static const List<Color> auroraGradient = [
    Color(0xFF120F2E),
    Color(0xFF2D1B56),
    Color(0xFF432C73),
  ];

  static const List<Color> sunriseGradient = [
    Color(0xFFFF9EB3),
    Color(0xFFFFB48B),
    Color(0xFFFFE8C5),
  ];

  static const List<Color> calmGradient = [
    Color(0xFF3C7CFF),
    Color(0xFF52E1FF),
  ];
}
