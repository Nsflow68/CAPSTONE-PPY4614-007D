import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';
import 'package:mi_refugio_app/shared/constants/app_shadows.dart';

class WellnessPage extends StatelessWidget {
  const WellnessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bienestar'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        children: [
          _WellnessCard(
            title: 'Hidratación',
            subtitle: 'Registra tu agua',
            assetPath: 'assets/images/nutrition/frutas.svg', // Placeholder or use specific water icon if available
            isIcon: true,
            iconData: Icons.water_drop_rounded,
            color: AppColors.primary,
            onTap: () => context.go('/wellness/hydration'),
          ),
          _WellnessCard(
            title: 'Nutrición',
            subtitle: 'Comidas saludables',
            assetPath: 'assets/images/nutrition/frutas.svg',
            color: AppColors.pastelGreen,
            onTap: () => context.go('/wellness/nutrition'),
          ),
          _WellnessCard(
            title: 'Mindfulness',
            subtitle: 'Respiración y calma',
            assetPath: 'assets/images/wellness/meditar.svg',
            color: AppColors.tertiary,
            onTap: () => context.go('/wellness/mindfulness'),
          ),
        ],
      ),
    );
  }
}

class _WellnessCard extends StatelessWidget {
  const _WellnessCard({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    this.isIcon = false,
    this.iconData,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String assetPath;
  final bool isIcon;
  final IconData? iconData;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.soft,
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: isIcon
                  ? Icon(iconData, color: color, size: 36)
                  : SvgPicture.asset(
                      assetPath,
                      width: 36,
                      height: 36,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
