
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100), // Extra padding for bottom nav
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Greeting
              _AnimatedGreeting(displayName: displayName, delay: 0),
              const SizedBox(height: 24),

              // Emotional Check-in Card (New)
              _AnimatedCard(
                delay: 100,
                child: _EmotionalCheckInCard(
                  onTap: () => context.go('/diary/entry/new'),
                ),
              ),
              const SizedBox(height: 24),

              // Daily Message / Wellness Plan
              _AnimatedCard(
                delay: 200,
                child: _DailyWellnessPlan(displayName: displayName),
              ),
              const SizedBox(height: 24),

              Text(
                'Explora tu bienestar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Feature Cards Row
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
                          colors: [Color(0xFFC3B1E1), Color(0xFFAEC6CF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.self_improvement_rounded,
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
                        subtitle: 'Balance y registro de comidas',
                        buttonText: 'Ver más',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF77DD77), Color(0xFFAEC6CF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.restaurant_rounded,
                        onTap: () => context.go('/wellness/nutrition'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Section
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
    );
  }
}

// Animated Greeting Widget
class _AnimatedGreeting extends StatelessWidget {
  final String displayName;
  final int delay;

  const _AnimatedGreeting({required this.displayName, required this.delay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, $displayName! 👋',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Es un buen momento para conectar contigo.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Card Wrapper
class _AnimatedCard extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedCard({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// Emotional Check-in Card
class _EmotionalCheckInCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmotionalCheckInCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryBubble,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mood_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Cómo te sientes?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registra tu emoción ahora',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}


// Daily Wellness Plan
class _DailyWellnessPlan extends ConsumerWidget {
  final String displayName;

  const _DailyWellnessPlan({required this.displayName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We use a FutureProvider or just call the service directly here for simplicity
    // Ideally, this should be a provider, but for now we'll use a FutureBuilder
    // to keep it self-contained or better yet, create a provider for it.
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.surfaceAlt),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.secondary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Mensaje del día',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                    height: 1.4,
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
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Mi Refugio',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Large Feature Card
class _LargeFeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final Gradient gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _LargeFeatureCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.gradient,
    required this.icon,
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: (widget.gradient.colors.first).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.buttonText,
                      style: TextStyle(
                        color: widget.gradient.colors.first,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: widget.gradient.colors.first,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quick Actions Row
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
            subtitle: 'Registrar',
            color: AppColors.primary,
            onTap: () => context.go('/wellness/hydration'),
          ),
          const SizedBox(width: 16),
          _TipCard(
            icon: Icons.restaurant_menu_rounded,
            title: 'Comida',
            subtitle: 'Agregar',
            color: AppColors.pastelGreen,
            onTap: () => context.go('/wellness/nutrition'),
          ),
          const SizedBox(width: 16),
          _TipCard(
            icon: Icons.smart_toy_rounded,
            title: 'ChatBot',
            subtitle: 'Conversar',
            color: AppColors.tertiary,
            onTap: () => context.go('/home/chatbot'),
          ),
        ],
      ),
    );
  }
}

// Tip Card
class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadows.soft,
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
