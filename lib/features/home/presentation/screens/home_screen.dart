import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mr_app/core/theme/app_theme.dart';
import 'package:mr_app/features/home/presentation/widgets/emotion_chart_card.dart';
import 'package:mr_app/features/home/presentation/widgets/mood_track_card.dart';
import 'package:mr_app/features/home/presentation/widgets/wellness_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              title: Text(
                'Mi Refugio',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hogar',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    EmotionChartCard(
                      spots: const [], // TODO: Add real data
                      title: 'Emociones',
                      subtitle: 'Tu registro semanal',
                    ),
                    SizedBox(height: 24.h),
                    WellnessCard(
                      title: 'Mindfulness',
                      icon: Icon(
                        Icons.self_improvement,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                      value: '15 min',
                      subtitle: 'Meditación diaria',
                      color: AppColors.primary,
                      onTap: () {},
                      action: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Ver más',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    WellnessCard(
                      title: 'Alimentación',
                      icon: Icon(
                        Icons.restaurant_menu,
                        color: AppColors.success,
                        size: 24.sp,
                      ),
                      value: '1800 / 2200',
                      subtitle: 'kcal consumidas',
                      color: AppColors.success,
                      onTap: () {},
                      action: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Ver más',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    WellnessCard(
                      title: 'Hidratación',
                      icon: Icon(
                        Icons.water_drop,
                        color: AppColors.secondary,
                        size: 24.sp,
                      ),
                      value: '1.2 / 2.0 L',
                      subtitle: 'agua consumida',
                      color: AppColors.secondary,
                      onTap: () {},
                      action: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Ver más',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Ayuda de salud mental',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    MoodTrackCard(
                      title: 'Línea de ayuda',
                      subtitle: 'Atención 24/7',
                      icon: Icons.phone,
                      color: AppColors.primary,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
