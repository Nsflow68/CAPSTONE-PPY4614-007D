import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_shadows.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE3DEFF),
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: Color(0xFFFFE0EC),
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD7FBF5),
      onTertiaryContainer: AppColors.textPrimary,
      error: Color(0xFFEA5A66),
      onError: Colors.white,
      errorContainer: Color(0xFFFFE8E9),
      onErrorContainer: Color(0xFF7A1720),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceAlt,
      onSurfaceVariant: AppColors.textSecondary,
      outline: Color(0xFFD1C9E4),
      outlineVariant: Color(0xFFE7E1F4),
      scrim: Colors.black54,
      shadow: Colors.black26,
      inverseSurface: AppColors.backgroundDark,
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.tertiary,
      surfaceTint: AppColors.primary,
    );

    final textTheme = GoogleFonts.nunitoTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
        shadowColor: AppShadows.soft.first.color,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: textTheme.bodyMedium,
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.9),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.6),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE6E0F2),
        space: 24,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.primary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        iconColor: AppColors.primary,
      ),
    );
  }

  static ThemeData dark() {
    final base = light();
    const darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFD4C9FF),
      onPrimary: AppColors.textPrimary,
      primaryContainer: Color(0xFF3B2F63),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xFFFFC1D9),
      onSecondary: Color(0xFF2D1221),
      secondaryContainer: Color(0xFF3C1E32),
      onSecondaryContainer: Colors.white,
      tertiary: Color(0xFF62F2E6),
      onTertiary: Color(0xFF082B2A),
      tertiaryContainer: Color(0xFF0D3A3A),
      onTertiaryContainer: Colors.white,
      error: Color(0xFFFFB4AC),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Colors.white,
      surface: Color(0xFF0F1020),
      onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF201F37),
      onSurfaceVariant: Color(0xFFD7CCE9),
      outline: Color(0xFF61597A),
      outlineVariant: Color(0xFF372F4B),
      scrim: Colors.black,
      shadow: Colors.black54,
      inverseSurface: AppColors.background,
      onInverseSurface: AppColors.textPrimary,
      inversePrimary: AppColors.primary,
      surfaceTint: Color(0xFFC6B5FF),
    );

    return base.copyWith(
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkScheme.surface,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: darkScheme.surface,
        foregroundColor: darkScheme.onSurface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      cardTheme: base.cardTheme.copyWith(color: darkScheme.surface),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: darkScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: darkScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: darkScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: darkScheme.primary, width: 1.6),
        ),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        indicatorColor: darkScheme.primary.withValues(alpha: 0.2),
      ),
      iconTheme: base.iconTheme.copyWith(color: darkScheme.primary),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: darkScheme.surface,
      ),
      snackBarTheme: base.snackBarTheme.copyWith(
        backgroundColor: darkScheme.surface,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: darkScheme.onSurface,
        ),
      ),
    );
  }
}
