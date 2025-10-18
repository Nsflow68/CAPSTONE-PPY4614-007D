import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:mr_app/core/constants/app_theme.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppGradients.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),
                      Lottie.asset(
                            'assets/animations/growth.json',
                            height: 180.h,
                          )?.animate().scale(
                            duration: AppAnimations.slow,
                            curve: Curves.easeOut,
                          ) ??
                          const SizedBox(),
                      SizedBox(height: 40.h),
                      Text(
                            'Crea tu cuenta',
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.surface,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: AppAnimations.medium)
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                      SizedBox(height: 8.h),
                      Text(
                            'Únete a una comunidad de bienestar emocional',
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.surface.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate()
                          .fadeIn(
                            duration: AppAnimations.medium,
                            delay: AppAnimations.shortDelay,
                          )
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                      SizedBox(height: 40.h),
                      _buildTextField(
                            hint: 'Nombre completo',
                            icon: Icons.person_outline,
                          )
                          .animate()
                          .fadeIn(
                            duration: AppAnimations.medium,
                            delay: AppAnimations.mediumDelay,
                          )
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                      SizedBox(height: 16.h),
                      _buildTextField(
                            hint: 'Correo electrónico',
                            icon: Icons.email_outlined,
                          )
                          .animate()
                          .fadeIn(
                            duration: AppAnimations.medium,
                            delay:
                                AppAnimations.mediumDelay +
                                const Duration(milliseconds: 100),
                          )
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                      SizedBox(height: 16.h),
                      _buildTextField(
                            hint: 'Contraseña',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          )
                          .animate()
                          .fadeIn(
                            duration: AppAnimations.medium,
                            delay: AppAnimations.longDelay,
                          )
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                      SizedBox(height: 16.h),
                      _buildTextField(
                            hint: 'Confirmar contraseña',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          )
                          .animate()
                          .fadeIn(
                            duration: AppAnimations.medium,
                            delay:
                                AppAnimations.longDelay +
                                const Duration(milliseconds: 100),
                          )
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                      SizedBox(height: 40.h),
                      _buildButton(text: 'Registrarse', onPressed: () {})
                          .animate()
                          .fadeIn(
                            duration: AppAnimations.medium,
                            delay:
                                AppAnimations.longDelay +
                                AppAnimations.mediumDelay,
                          )
                          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: () {},
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.surface,
                            ),
                            children: [
                              const TextSpan(text: '¿Ya tienes una cuenta? '),
                              TextSpan(
                                text: 'Inicia sesión',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(
                        duration: AppAnimations.fast,
                        delay:
                            AppAnimations.longDelay + AppAnimations.longDelay,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: AppDecorations.surfaceCard.copyWith(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPassword,
        style: AppTextStyles.body1,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body1.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 24.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Material(
      color: isOutlined ? Colors.transparent : AppColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: isOutlined
                ? Border.all(color: AppColors.surface, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.button.copyWith(
                color: isOutlined ? AppColors.surface : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
