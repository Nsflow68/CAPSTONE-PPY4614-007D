import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.favorite_rounded,
                size: 80.h,
                color: Colors.white,
              )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                duration: const Duration(seconds: 2),
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
              ).then()
              .scale(
                duration: const Duration(seconds: 2),
                begin: const Offset(1.2, 1.2),
                end: const Offset(1, 1),
              ),
              SizedBox(height: 40.h),
              Text(
                'Mi Refugio',
                style: GoogleFonts.poppins(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ).animate().fadeIn(duration: const Duration(milliseconds: 800)),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'Tu espacio seguro para el\nbienestar emocional',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 200),
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    _buildButton(
                      context,
                      'Comenzar',
                      onPressed: () {},
                    ),
                    SizedBox(height: 16.h),
                    _buildButton(
                      context,
                      'Ya tengo una cuenta',
                      onPressed: () {},
                      isOutlined: true,
                    ),
                  ].animate(interval: 200.ms)
                   .fadeIn(duration: 600.ms)
                   .slideY(begin: 0.3, end: 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text, {
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Material(
      color: isOutlined ? Colors.transparent : Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: isOutlined
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: isOutlined
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}