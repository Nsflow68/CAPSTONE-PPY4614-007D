import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_gradients.dart';
import '../../../../shared/constants/app_shadows.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../../core/services/daily_message_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final displayName = authState.maybeWhen(
      authenticated: (user) => user.name.split(' ').first,
      orElse: () => 'Usuario',
    );
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Elements (Subtle Blobs)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Header with Mascot
                  _MascotHeader(displayName: displayName),
                  const SizedBox(height: 32),

                  // Emotional Check-in (Floating Glass Card)
                  _AnimatedCard(
                    delay: 100,
                    child: _EmotionalCheckInCard(
                      onTap: () => context.go('/diary/entry/new'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Daily Message
                  _AnimatedCard(
                    delay: 200,
                    child: _DailyWellnessPlan(displayName: displayName),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Explora tu bienestar',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feature Cards
                  _AnimatedCard(
                    delay: 300,
                    child: Row(
                      children: [
                        Expanded(
                          child: _LargeFeatureCard(
                            title: 'Calma',
                            subtitle: 'Mindfulness y respiración',
                            buttonText: 'Iniciar',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE1BEE7), Color(0xFFD1C4E9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            iconAsset: 'assets/images/iconos/meditar.svg',
                            onTap: () => context.go('/wellness/mindfulness'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedCard(
                    delay: 400,
                    child: Row(
                      children: [
                        Expanded(
                          child: _LargeFeatureCard(
                            title: 'Nutrición',
                            subtitle: 'Balance y registro',
                            buttonText: 'Ver más',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            iconAsset: 'assets/images/nutrition/frutas.svg',
                            onTap: () => context.go('/wellness/nutrition'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Quick Actions
                  _AnimatedCard(
                    delay: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acciones rápidas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _QuickActionsRow(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotHeader extends StatelessWidget {
  final String displayName;

  const _MascotHeader({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBBDEFB).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola, $displayName!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1565C0),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Es un buen momento para conectar contigo mismo.',
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(0xFF1565C0).withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SvgPicture.asset(
            'assets/images/mascot/pose1.svg',
            height: 100,
          ),
        ],
      ),
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedCard({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _EmotionalCheckInCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmotionalCheckInCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF5F7FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadows.soft,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mood_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Cómo te sientes?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Registra tu emoción ahora',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                ),
              child: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyWellnessPlan extends ConsumerWidget {
  final String displayName;

  const _DailyWellnessPlan({required this.displayName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFFB74D), size: 24),
              const SizedBox(width: 12),
              Text(
                'Mensaje del día',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<String>(
            future: ref.read(dailyMessageServiceProvider).getDailyMessage(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  '"${snapshot.data}"',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                );
              }
              return const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LargeFeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final Gradient gradient;
  final String iconAsset;
  final VoidCallback onTap;

  const _LargeFeatureCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.gradient,
    required this.iconAsset,
    required this.onTap,
  });

  @override
  State<_LargeFeatureCard> createState() => _LargeFeatureCardState();
}

class _LargeFeatureCardState extends State<_LargeFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: (widget.gradient.colors.first).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 24,
                left: 24,
                right: 120,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -10,
                bottom: -10,
                child: SvgPicture.asset(
                  widget.iconAsset,
                  width: 100,
                  height: 100,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _TipCard(
            icon: Icons.water_drop_rounded,
            title: 'Hidratación',
            color: const Color(0xFF4FC3F7),
            onTap: () => context.go('/wellness/hydration'),
          ),
          const SizedBox(width: 16),
          _TipCard(
            icon: Icons.restaurant_menu_rounded,
            title: 'Comida',
            color: const Color(0xFFAED581),
            onTap: () => context.go('/wellness/nutrition'),
          ),
          const SizedBox(width: 16),
          _TipCard(
            icon: Icons.smart_toy_rounded,
            title: 'ChatBot',
            color: const Color(0xFF9575CD),
            onTap: () => context.go('/home/chatbot'),
            useImage: true,
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool useImage;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.useImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: useImage
                  ? Image.asset('assets/images/branding/bot_avatar.png',
                      width: 24, height: 24)
                  : Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}