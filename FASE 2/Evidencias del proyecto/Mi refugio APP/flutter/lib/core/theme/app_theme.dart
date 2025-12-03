import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/constants/app_colors.dart';

/// Sistema de tema "Radical Redesign" (2025-2026) para Mi Refugio.
///
/// Enfoque:
/// - Empatía y Calma (Paleta Pastel)
/// - Accesibilidad (Contraste AA+)
/// - Material 3 Expressive (Radio de borde amplio, tipografía redondeada)
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════
  // CONSTANTES DE DISEÑO
  // ═══════════════════════════════════════════════════════════════════════

  static const double radiusSmall = 16.0;
  static const double radiusMedium = 24.0;
  static const double radiusLarge = 32.0;
  static const double radiusCard = 28.0;

  // ═══════════════════════════════════════════════════════════════════════
  // PALETA PASTEL (Definición)
  // ═══════════════════════════════════════════════════════════════════════

  // Azul Calma (Primary)
  static const _pastelBlue = Color(0xFF8EB1C7);
  static const _pastelBlueDark = Color(0xFF5A7D9A);
  static const _pastelBlueContainer = Color(0xFFD8EBF5);

  // Rosa Suave (Secondary)
  static const _pastelPink = Color(0xFFE2B6CF);
  static const _pastelPinkDark = Color(0xFFA67C94);
  static const _pastelPinkContainer = Color(0xFFF8E1EE);

  // Lila (Tertiary)
  static const _pastelLilac = Color(0xFFB0A3D6);
  static const _pastelLilacContainer = Color(0xFFEBE5F7);

  // Beige/Neutros (Backgrounds)
  static const _warmBeige = Color(0xFFF9F7F2);
  static const _softSurface = Colors.white;
  static const _textPrimary = Color(0xFF2D3142); // Gris oscuro cálido
  static const _textSecondary = Color(0xFF6C757D);

  // ═══════════════════════════════════════════════════════════════════════
  // TEMA CLARO
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      // Primary (Azul)
      primary: _pastelBlue,
      onPrimary: Colors.white,
      primaryContainer: _pastelBlueContainer,
      onPrimaryContainer: _textPrimary,
      // Secondary (Rosa)
      secondary: _pastelPink,
      onSecondary: _textPrimary,
      secondaryContainer: _pastelPinkContainer,
      onSecondaryContainer: _textPrimary,
      // Tertiary (Lila)
      tertiary: _pastelLilac,
      onTertiary: Colors.white,
      tertiaryContainer: _pastelLilacContainer,
      onTertiaryContainer: _textPrimary,
      // Error
      error: Color(0xFFE57373),
      onError: Colors.white,
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFFC62828),
      // Surfaces
      surface: _softSurface,
      onSurface: _textPrimary,
      surfaceContainerHighest: Color(0xFFF0F2F5),
      onSurfaceVariant: _textSecondary,
      // Background
      outline: Color(0xFFD1D9E0),
      outlineVariant: Color(0xFFE8EDF2),
      shadow: Colors.black12,
      scrim: Colors.black45,
    );

    // Tipografía: Nunito (Redondeada y Amigable)
    final textTheme = GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: _textPrimary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: _textPrimary,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600, // Semi-bold para mejor legibilidad
        color: _textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _warmBeige,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: _warmBeige,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _textPrimary,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),

      // Cards
      cardTheme: const CardThemeData(
        color: _softSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusCard)),
          side: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: _pastelBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          ),
          textStyle: textTheme.titleMedium?.copyWith(fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          foregroundColor: _pastelBlueDark,
          side: const BorderSide(color: _pastelBlue, width: 2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          ),
          textStyle: textTheme.titleMedium?.copyWith(fontSize: 16),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: const BorderSide(color: _pastelBlue, width: 2),
        ),
        labelStyle: TextStyle(color: _textSecondary),
        prefixIconColor: _pastelBlue,
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        height: 72,
        indicatorColor: _pastelBlueContainer,
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _pastelBlueDark, size: 26);
          }
          return const IconThemeData(color: _textSecondary, size: 24);
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TEMA OSCURO (Adaptado)
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData dark() {
    // Por ahora, usamos una versión simplificada oscura que respeta la paleta
    // pero invierte superficies.
    const darkBg = Color(0xFF1A1C23);
    const darkSurface = Color(0xFF252830);

    return ThemeData.dark().copyWith(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: _pastelBlue,
        onPrimary: darkBg,
        secondary: _pastelPink,
        onSecondary: darkBg,
        surface: darkSurface,
        onSurface: Color(0xFFE0E0E0),
        background: darkBg,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),
    );
  }
}
