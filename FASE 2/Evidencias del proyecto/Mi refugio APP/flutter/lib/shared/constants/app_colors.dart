import 'package:flutter/material.dart';

/// Sistema de colores profesional 2026 basado en la paleta de Mi Refugio.
///
/// Paleta diseñada para apps de bienestar emocional: tonos suaves, cálidos
/// y accesibles que reducen la carga cognitiva y transmiten calma.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════
  // COLORES PRINCIPALES (Radical Redesign 2025-2026)
  // ═══════════════════════════════════════════════════════════════════════

  /// Azul Calma (Primary)
  static const Color primary = Color(0xFF8EB1C7);

  /// Rosa Suave (Secondary)
  static const Color secondary = Color(0xFFE2B6CF);

  /// Lila (Tertiary)
  static const Color tertiary = Color(0xFFB0A3D6);

  /// Verde Pastel
  static const Color pastelGreen = Color(0xFFA5D6A7);

  // ═══════════════════════════════════════════════════════════════════════
  // FONDOS Y SUPERFICIES
  // ═══════════════════════════════════════════════════════════════════════

  /// Beige Cálido - Fondo general
  static const Color background = Color(0xFFF9F7F2);

  /// Blanco Suave - Superficies
  static const Color surface = Colors.white;

  /// Superficie Alternativa
  static const Color surfaceAlt = Color(0xFFF0F2F5);

  /// Fondo oscuro para modo dark
  static const Color backgroundDark = Color(0xFF1A1C23);

  // ═══════════════════════════════════════════════════════════════════════
  // TEXTOS
  // ═══════════════════════════════════════════════════════════════════════

  /// Gris oscuro cálido - Texto principal
  static const Color textPrimary = Color(0xFF2D3142);

  /// Gris medio - Texto secundario
  static const Color textSecondary = Color(0xFF6C757D);

  /// Gris claro - Texto deshabilitado
  static const Color textDisabled = Color(0xFFBDBDBD);

  // ═══════════════════════════════════════════════════════════════════════
  // ESTADOS Y RETROALIMENTACIÓN
  // ═══════════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFFB8D6B8);
  static const Color warning = Color(0xFFF5E0B8);
  static const Color danger = Color(0xFFE57373);
  static const Color info = Color(0xFF8EB1C7);

  // ═══════════════════════════════════════════════════════════════════════
  // PALETA EMOCIONAL
  // ═══════════════════════════════════════════════════════════════════════

  static const Color moodJoy = Color(0xFFF5E0B8);
  static const Color moodCalm = Color(0xFF8EB1C7);
  static const Color moodSad = Color(0xFFB0A3D6);
  static const Color moodAngry = Color(0xFFE57373);
  static const Color moodAnxious = Color(0xFFE2B6CF);
  static const Color moodNeutral = Color(0xFFD8D8D8);

  // ═══════════════════════════════════════════════════════════════════════
  // GRADIENTES
  // ═══════════════════════════════════════════════════════════════════════

  static const List<Color> softBackground = [
    Color(0xFFF9F7F2),
    Color(0xFFF0F2F5),
  ];

  static const List<Color> primaryGradient = [
    Color(0xFF8EB1C7),
    Color(0xFFB0A3D6),
  ];

  static const List<Color> warmGradient = [
    Color(0xFFE2B6CF),
    Color(0xFFF5E0B8),
  ];
}
