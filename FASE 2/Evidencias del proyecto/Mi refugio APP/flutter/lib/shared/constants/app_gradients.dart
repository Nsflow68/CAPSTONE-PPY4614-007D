import 'package:flutter/material.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient softBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.background, AppColors.surfaceAlt],
  );

  static const LinearGradient cardPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.tertiary],
  );

  static const LinearGradient cardSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondary, AppColors.surfaceAlt],
  );

  static const LinearGradient cardAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.tertiary, AppColors.primary],
  );

  static const LinearGradient primaryBubble = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primary, AppColors.tertiary],
  );
}
