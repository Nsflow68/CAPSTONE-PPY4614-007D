import 'package:flutter/material.dart';

/// Sistema de colores profesional 2026 basado en la paleta de Mi Refugio.
///
/// Paleta diseñada para apps de bienestar emocional: tonos suaves, cálidos
/// y accesibles que reducen la carga cognitiva y transmiten calma.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════
  // COLORES PRINCIPALES (basados en la paleta de referencia)
  // ═══════════════════════════════════════════════════════════════════════

  /// Azul claro/celeste - Calma, serenidad, confianza
  static const Color primary = Color(0xFFB8D6E2);

  /// Rosa suave - Calidez, empatía, contención emocional
  static const Color secondary = Color(0xFFE8C1C1);

  /// Lila/lavanda - Introspección, creatividad, bienestar
  static const Color tertiary = Color(0xFFC5B4F0);

  // ═══════════════════════════════════════════════════════════════════════
  // FONDOS Y SUPERFICIES
  // ═══════════════════════════════════════════════════════════════════════

  /// Crema cálido - Fondo general de la app
  static const Color background = Color(0xFFF5EEE6);

  /// Blanco cálido - Superficies elevadas (tarjetas, inputs)
  static const Color surface = Color(0xFFFFFBF7);

  /// Crema más oscuro - Superficies alternativas
  static const Color surfaceAlt = Color(0xFFEDE5D8);

  /// Fondo oscuro para modo dark (futuro)
  static const Color backgroundDark = Color(0xFF1A1A1A);

  // ═══════════════════════════════════════════════════════════════════════
  // TEXTOS
  // ═══════════════════════════════════════════════════════════════════════

  /// Gris oscuro - Texto principal (contraste AA+)
  static const Color textPrimary = Color(0xFF535353);

  /// Gris medio - Texto secundario, subtítulos
  static const Color textSecondary = Color(0xFF8B8B8B);

  /// Gris claro - Texto deshabilitado, placeholders
  static const Color textDisabled = Color(0xFFBDBDBD);

  // ═══════════════════════════════════════════════════════════════════════
  // ESTADOS Y RETROALIMENTACIÓN
  // ═══════════════════════════════════════════════════════════════════════

  /// Verde suave - Éxito, confirmación
  static const Color success = Color(0xFFB8D6B8);

  /// Amarillo suave - Advertencia
  static const Color warning = Color(0xFFF5E0B8);

  /// Coral suave - Error, peligro
  static const Color danger = Color(0xFFE8B8B8);

  /// Azul información
  static const Color info = Color(0xFFB8D6E2);

  // ═══════════════════════════════════════════════════════════════════════
  // PALETA EMOCIONAL (para diario y chatbot)
  // ═══════════════════════════════════════════════════════════════════════

  static const Color moodJoy = Color(0xFFF5E0B8); // Alegría - amarillo suave
  static const Color moodCalm = Color(0xFFB8D6E2); // Calma - azul claro
  static const Color moodSad = Color(0xFFC5B4F0); // Tristeza - lila
  static const Color moodAngry = Color(0xFFE8B8B8); // Enojo - coral
  static const Color moodAnxious = Color(0xFFE8C1C1); // Ansiedad - rosa
  static const Color moodNeutral = Color(0xFFD8D8D8); // Neutral - gris claro

  // ═══════════════════════════════════════════════════════════════════════
  // GRADIENTES
  // ═══════════════════════════════════════════════════════════════════════

  /// Gradiente suave para fondos decorativos
  static const List<Color> softBackground = [
    Color(0xFFF5EEE6),
    Color(0xFFEDE5D8),
  ];

  /// Gradiente primario para elementos destacados
  static const List<Color> primaryGradient = [
    Color(0xFFB8D6E2),
    Color(0xFFC5B4F0),
  ];

  /// Gradiente cálido para acentos emocionales
  static const List<Color> warmGradient = [
    Color(0xFFE8C1C1),
    Color(0xFFF5E0B8),
  ];
}
