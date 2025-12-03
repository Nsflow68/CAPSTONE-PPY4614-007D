import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_refugio_app/features/auth/application/auth_provider.dart';
import 'package:mi_refugio_app/features/auth/application/auth_state.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';
import 'dart:ui';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final displayName = user?.name?.split(' ').first ?? 'Viajero';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
            children: [
              // Greeting Header with animation
              _AnimatedGreeting(displayName: displayName, delay: 0),
              const SizedBox(height: 24),

              // Daily Wellness Plan with improved gradient
              _AnimatedCard(
                delay: 100,
                child: _DailyWellnessPlan(displayName: displayName),
              ),
              const SizedBox(height: 24),

              // Calma Card with ocean gradient
              _AnimatedCard(
                delay: 200,
                child: _LargeFeatureCard(
                  title: 'Calma',
                  subtitle: 'Respira y encuentra tu paz interior',
                  buttonText: 'Explorar ejercicios',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  icon: Icons.self_improvement,
                  onTap: () => context.go('/home/mindfulness'),
                ),
              ),
              const SizedBox(height: 24),

              // Nutrition Card
              _AnimatedCard(
                delay: 300,
                child: _LargeFeatureCard(
                  title: 'Nutrición',
                  subtitle: 'Cuida tu alimentación y bienestar',
                  buttonText: 'Ver mi progreso',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  icon: Icons.restaurant_menu,
                  onTap: () => context.go('/home/nutrition'),
                ),
              ),
              const SizedBox(height: 24),

              // Tips Section
              _AnimatedCard(
                delay: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips rápidos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _QuickTipsRow(),
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
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¿Cómo te sientes hoy?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
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

// Daily Wellness Plan with improved gradient
class _DailyWellnessPlan extends StatelessWidget {
  final String displayName;

  const _DailyWellnessPlan({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF667eea), // Blue violet
            Color(0xFF764ba2), // Purple
            Color(0xFFf093fb), // Pink
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mi Refugio',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Registra tu emoción de hoy y descubre recomendaciones personalizadas.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Plan de bienestar diario',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Activa recordatorios, revisa emociones recientes y continúa tu rutina.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _GlassChip(icon: Icons.favorite_border, label: 'Bienestar'),
              const SizedBox(width: 12),
              _GlassChip(icon: Icons.calendar_today, label: 'Hoy'),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Registrar\nemoción',
                  icon: Icons.edit_note,
                  isPrimary: true,
                  onTap: () => context.go('/diary'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionButton(
                  label: 'Ver logros',
                  icon: Icons.emoji_events,
                  isPrimary: false,
                  onTap: () => context.go('/home/rewards'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Glass Chip with backdrop blur
class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GlassChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Action Button with micro-interactions
class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
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
          height: 64,
          decoration: BoxDecoration(
            color: widget.isPrimary ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(18),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: widget.isPrimary ? const Color(0xFF667eea) : Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.isPrimary ? const Color(0xFF667eea) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Large Feature Card with custom gradient
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

class _LargeFeatureCardState extends State<_LargeFeatureCard> with SingleTickerProviderStateMixin {
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
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
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
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: (widget.gradient.colors.first).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 32),
                  ),
                ],
              ),
              if (widget.buttonText.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.buttonText,
                        style: TextStyle(
                          color: widget.gradient.colors.first,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: widget.gradient.colors.first,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Quick Tips Row
class _QuickTipsRow extends StatelessWidget {
  const _QuickTipsRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TipCard(
            icon: Icons.water_drop,
            title: 'Hidratación',
            subtitle: '6/8 vasos',
            color: const Color(0xFF4DD0E1),
            onTap: () {},
          ),
          const SizedBox(width: 16),
          _TipCard(
            icon: Icons.bedtime,
            title: 'Descanso',
            subtitle: '7h 30m',
            color: const Color(0xFF9575CD),
            onTap: () {},
          ),
          const SizedBox(width: 16),
          _TipCard(
            icon: Icons.directions_walk,
            title: 'Actividad',
            subtitle: '8,432 pasos',
            color: const Color(0xFF81C784),
            onTap: () {},
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
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
