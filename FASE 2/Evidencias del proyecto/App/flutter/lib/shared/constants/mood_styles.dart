import "package:flutter/material.dart";
import "package:mi_refugio_app/shared/constants/app_colors.dart";

class MoodStyles {
  MoodStyles._();

  static Color background(String mood) {
    switch (mood.toLowerCase()) {
      case "alegre":
      case "feliz":
        return AppColors.moodJoy.withValues(alpha: 0.18);
      case "calma":
      case "en calma":
        return AppColors.moodCalm.withValues(alpha: 0.2);
      case "triste":
        return AppColors.moodSad.withValues(alpha: 0.18);
      case "enojado":
      case "ansioso":
        return AppColors.moodAngry.withValues(alpha: 0.18);
      default:
        return AppColors.moodNeutral.withValues(alpha: 0.2);
    }
  }

  static Color text(String mood) {
    switch (mood.toLowerCase()) {
      case "alegre":
      case "feliz":
        return AppColors.moodJoy.darken();
      case "calma":
      case "en calma":
        return AppColors.moodCalm.darken();
      case "triste":
        return AppColors.moodSad.darken();
      case "enojado":
      case "ansioso":
        return AppColors.moodAngry.darken();
      default:
        return AppColors.moodNeutral.darken();
    }
  }
}

extension on Color {
  Color darken([double amount = 0.2]) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
