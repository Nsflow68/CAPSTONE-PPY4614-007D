import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFFFF7D63);
  static const secondary = Color(0xFFFFB073);
  static const tertiary = Color(0xFF81C784);
  static const background = Color(0xFFFFF3E0);
  static const error = Color(0xFFD32F2F);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF2D3142);
  static const textSecondary = Color(0xFF9C9EAA);
}

class AppGradients {
  static const mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFA897), Color(0xFFFFBE98)],
  );
}

class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.poppins(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get heading2 => GoogleFonts.poppins(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get body1 => GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get body2 => GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
    height: 1.5,
  );
}

class AppDecorations {
  static BoxDecoration get gradientCard => BoxDecoration(
    gradient: AppGradients.cardGradient,
    borderRadius: BorderRadius.circular(16.r),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.2),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration get surfaceCard => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16.r),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class AppAnimations {
  static Duration get fast => const Duration(milliseconds: 300);
  static Duration get medium => const Duration(milliseconds: 500);
  static Duration get slow => const Duration(milliseconds: 800);

  static Duration get shortDelay => const Duration(milliseconds: 200);
  static Duration get mediumDelay => const Duration(milliseconds: 400);
  static Duration get longDelay => const Duration(milliseconds: 600);
}
