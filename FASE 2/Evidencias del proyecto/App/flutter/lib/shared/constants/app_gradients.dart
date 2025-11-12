import 'package:flutter/material.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient softBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFDF8F1), Color(0xFFF6F1FF)],
  );

  static const LinearGradient cardPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, Color(0xFF9D8AF0)],
  );

  static const LinearGradient cardSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFCE6F1), Color(0xFFFDF4E9)],
  );

  static const LinearGradient cardAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA6E4D3), Color(0xFFBEE9FF)],
  );

  static const LinearGradient primaryBubble = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primary, Color(0xFF9D8AF0)],
  );
}
