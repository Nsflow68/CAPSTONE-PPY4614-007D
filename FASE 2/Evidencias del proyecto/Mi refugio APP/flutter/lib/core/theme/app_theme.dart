import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/constants/app_colors.dart';

/// Sistema de tema profesional para Mi Refugio.
///
/// Define un ThemeData consistente basado en Material 3 con:
/// - Paleta de colores calmada y profesional
/// - Tipografía legible y accesible
/// - Componentes con estilos uniformes
/// - Optimizado para rendimiento
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════
  // CONSTANTES DE DISEÑO
  // ═══════════════════════════════════════════════════════════════════════

  /// Radio de borde estándar para componentes pequeños
  static const double radiusSmall = 12.0;

  /// Radio de borde estándar para componentes medianos
  static const double radiusMedium = 16.0;

  /// Radio de borde estándar para componentes grandes
  static const double radiusLarge = 24.0;

  /// Radio de borde estándar para tarjetas
  static const double radiusCard = 20.0;

  /// Espaciado base (para multiplicar: 2x, 3x, etc.)
  static const double spacingBase = 8.0;

  // ═══════════════════════════════════════════════════════════════════════
  // TEMA CLARO
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      // Colores primarios
      primary: AppColors.primary,
      onPrimary: AppColors.textPrimary,
      primaryContainer: Color(0xFFD4E9F0),
      onPrimaryContainer: AppColors.textPrimary,
      // Colores secundarios
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: Color(0xFFF5E0E0),
      onSecondaryContainer: AppColors.textPrimary,
      // Colores terciarios
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.textPrimary,
      tertiaryContainer: Color(0xFFE6DFF8),
      onTertiaryContainer: AppColors.textPrimary,
      // Estados
      error: AppColors.danger,
      onError: AppColors.textPrimary,
      errorContainer: Color(0xFFF8E6E6),
      onErrorContainer: AppColors.textPrimary,
      // Superficies
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceAlt,
      onSurfaceVariant: AppColors.textSecondary,
      // Bordes
      outline: Color(0xFFD8D0C8),
      outlineVariant: Color(0xFFEDE5D8),
      // Otros
      scrim: Colors.black54,
      shadow: Colors.black12,
      inverseSurface: AppColors.backgroundDark,
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.tertiary,
      surfaceTint: AppColors.primary,
    );

    // Tipografía optimizada para legibilidad
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      // Headlines
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      // Titles
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      // Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      // Labels
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,

      // ═════════════════════════════════════════════════════════════════════
      // APP BAR
      // ═════════════════════════════════════════════════════════════════════

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: textTheme.titleLarge,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),

      // ═════════════════════════════════════════════════════════════════════
      // TARJETAS
      // ═════════════════════════════════════════════════════════════════════

      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusCard)),
        ),
        margin: EdgeInsets.zero,
        shadowColor: Colors.black12,
      ),

      // ═════════════════════════════════════════════════════════════════════
      // BOTONES
      // ═════════════════════════════════════════════════════════════════════

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.surfaceAlt,
          disabledForegroundColor: AppColors.textDisabled,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          ),
          textStyle: textTheme.titleMedium,
          minimumSize: const Size(88, 48),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.surfaceAlt,
          disabledForegroundColor: AppColors.textDisabled,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          ),
          textStyle: textTheme.titleMedium,
          minimumSize: const Size(88, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textDisabled,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          ),
          textStyle: textTheme.titleMedium,
          minimumSize: const Size(88, 48),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: textTheme.titleMedium,
          minimumSize: const Size(64, 40),
        ),
      ),

      // ═════════════════════════════════════════════════════════════════════
      // INPUTS
      // ═════════════════════════════════════════════════════════════════════

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
          borderSide: BorderSide(color: AppColors.danger, width: 2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textDisabled,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: AppColors.danger,
        ),
      ),

      // ═════════════════════════════════════════════════════════════════════
      // CHIPS
      // ═════════════════════════════════════════════════════════════════════

      chipTheme: ChipThemeData(
        labelStyle: textTheme.labelMedium,
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        disabledColor: AppColors.surfaceAlt.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        side: BorderSide.none,
      ),

      // ═════════════════════════════════════════════════════════════════════
      // NAVEGACIÓN
      // ═════════════════════════════════════════════════════════════════════

      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSmall)),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),

      // ═════════════════════════════════════════════════════════════════════
      // OTROS COMPONENTES
      // ═════════════════════════════════════════════════════════════════════

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0D8CC),
        space: 24,
        thickness: 1,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSmall)),
        ),
        actionTextColor: AppColors.primary,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLarge),
          ),
        ),
        elevation: 0,
        shadowColor: Colors.black12,
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        iconColor: AppColors.primary,
        minLeadingWidth: 40,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
        ),
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearMinHeight: 4,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.surfaceAlt,
        ),
      ),

      // ═════════════════════════════════════════════════════════════════════
      // TRANSICIONES
      // ═════════════════════════════════════════════════════════════════════

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TEMA OSCURO (Estructura base para futuras mejoras)
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData dark() {
    final base = light();

    const darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFD4E9F0),
      onPrimary: Color(0xFF1A1A1A),
      primaryContainer: Color(0xFF2B4A54),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xFFF5E0E0),
      onSecondary: Color(0xFF1A1A1A),
      secondaryContainer: Color(0xFF4A2B2B),
      onSecondaryContainer: Colors.white,
      tertiary: Color(0xFFE6DFF8),
      onTertiary: Color(0xFF1A1A1A),
      tertiaryContainer: Color(0xFF3A2F54),
      onTertiaryContainer: Colors.white,
      error: Color(0xFFF8E6E6),
      onError: Color(0xFF1A1A1A),
      errorContainer: Color(0xFF5A2B2B),
      onErrorContainer: Colors.white,
      surface: Color(0xFF1A1A1A),
      onSurface: Color(0xFFE8E8E8),
      surfaceContainerHighest: Color(0xFF2A2A2A),
      onSurfaceVariant: Color(0xFFB8B8B8),
      outline: Color(0xFF4A4A4A),
      outlineVariant: Color(0xFF3A3A3A),
      scrim: Colors.black,
      shadow: Colors.black54,
      inverseSurface: AppColors.surface,
      onInverseSurface: AppColors.textPrimary,
      inversePrimary: AppColors.primary,
      surfaceTint: Color(0xFFD4E9F0),
    );

    return base.copyWith(
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkScheme.surface,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: darkScheme.surface,
        foregroundColor: darkScheme.onSurface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: darkScheme.onSurface,
        displayColor: darkScheme.onSurface,
      ),
    );
  }
}
