import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_gradients.dart';
import '../widgets/guide_step_card.dart';
import '../widgets/user_journey_banner.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  static const _steps = [
    GuideStepData(
      title: 'Respira y explora',
      description:
          'Inicia sesión o ingresa como invitado, conoce tu panel de bienestar '
          'y registra tu emoción del día.',
      icon: Icons.self_improvement_rounded,
    ),
    GuideStepData(
      title: 'Crea hábitos conscientes',
      description:
          'Desde la casa puedes ir a Mindfulness, Alimentación o Hidratación '
          'para seguir planes semanales.',
      icon: Icons.auto_graph_rounded,
    ),
    GuideStepData(
      title: 'Acompañamiento experto',
      description:
          'Explora recursos profesionales y agéndate directamente con entidades verificadas.',
      icon: Icons.volunteer_activism_rounded,
    ),
    GuideStepData(
      title: 'Charla con Refu',
      description:
          'Accede al chatbot para ejercicios de respiración, técnicas de calma o conversación guiada.',
      icon: Icons.forum_rounded,
    ),
  ];

  static const _journey = [
    UserJourneyStep(
      title: 'Inicio',
      description: 'Resumen emocional, hábitos clave y accesos rápidos.',
      route: '/home',
      icon: Icons.home_rounded,
    ),
    UserJourneyStep(
      title: 'Diario',
      description: 'Registra emociones, etiquetas y recibe insights semanales.',
      route: '/diary',
      icon: Icons.menu_book_rounded,
    ),
    UserJourneyStep(
      title: 'Chatbot',
      description: 'Refu te acompaña con ejercicios y escucha activa.',
      route: '/chatbot',
      icon: Icons.bubble_chart_rounded,
    ),
    UserJourneyStep(
      title: 'Perfil',
      description: 'Configura notificaciones, modo oscuro y preferencias.',
      route: '/profile',
      icon: Icons.person_rounded,
    ),
  ];

  static const _moments = [

    _GuideMoment(

      title: 'Pulso diario',

      subtitle: 'Registra tu emoción base y respalda con notas o audio.',

      icon: Icons.favorite_rounded,

      route: '/diary',

    ),

    _GuideMoment(

      title: 'Hábito guiado',

      subtitle: 'Activa respiraciones, meditaciones o hidratación consciente.',

      icon: Icons.spa_rounded,

      route: '/home/mindfulness',

    ),

    _GuideMoment(

      title: 'Refu bot',

      subtitle: 'Recibe respuestas empáticas y ejercicios con Llama.',

      icon: Icons.bubble_chart_rounded,

      route: '/chatbot',

    ),

    _GuideMoment(

      title: 'Perfil y recompensas',

      subtitle: 'Configura metas, revisa logros y comparte con tu red.',

      icon: Icons.emoji_events_rounded,

      route: '/profile',

    ),

  ];



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _GuideHero(
                onStart: () => context.go('/home'),
              ),
              title: const Text('Guía Mi Refugio'),
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.softBackground,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recorrido recomendado',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    UserJourneyTimeline(steps: _journey),
                    const SizedBox(height: 24),
                    UserJourneyBanner(
                      highlight:
                          'Domina el flujo Inicio > Diario > Chatbot > Perfil con ejemplos guiados y video introductorio.',
                      onOpenGuide: () => context.go('/home'),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Momentos clave en tu recorrido',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GuideMomentsGrid(moments: _moments),
                    const SizedBox(height: 32),
                    Text(
                      'Cómo sacar el máximo provecho',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      runSpacing: 16,
                      children: _steps
                          .map(
                            (step) => GuideStepCard(
                              data: step,
                              onAction: () => _handleStepTap(context, step),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                    _SupportSection(
                      onResources: () => context.go('/home/resources'),
                      onDiary: () => context.go('/diary'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStepTap(BuildContext context, GuideStepData data) {
    if (data.title.startsWith('Respira')) {
      context.go('/home');
    } else if (data.title.startsWith('Crea')) {
      context.go('/home/mindfulness');
    } else if (data.title.contains('profesionales')) {
      context.go('/home/resources');
    } else {
      context.go('/chatbot');
    }
  }
}

class _GuideHero extends StatelessWidget {
  const _GuideHero({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7F79F9), Color(0xFF8BE1D0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Text(
              'Tu recorrido de bienestar',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Guía paso a paso con recomendaciones, accesos y tips para que Mi Refugio te acompañe todos los días.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Comenzar recorrido'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportSection extends StatelessWidget {
  const _SupportSection({required this.onResources, required this.onDiary});

  final VoidCallback onResources;
  final VoidCallback onDiary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Necesitas acompañamiento?',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SupportCard(
                icon: Icons.diversity_3_rounded,
                title: 'Recursos profesionales',
                description: 'Líneas, chats y directorios 24/7 verificados.',
                onTap: onResources,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SupportCard(
                icon: Icons.menu_book_rounded,
                title: 'Diario emocional',
                description: 'Escribe tu emoción y visualiza tus avances.',
                onTap: onDiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideMoment {
  const _GuideMoment({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

class _GuideMomentsGrid extends StatelessWidget {
  const _GuideMomentsGrid({required this.moments});

  final List<_GuideMoment> moments;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;
        final itemWidth = isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: moments
              .map(
                (moment) => SizedBox(
                  width: itemWidth,
                  child: _GuideMomentCard(moment: moment),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _GuideMomentCard extends StatelessWidget {
  const _GuideMomentCard({required this.moment});

  final _GuideMoment moment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => context.go(moment.route),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Icon(moment.icon, color: AppColors.primary),
            ),
            const SizedBox(height: 14),
            Text(
              moment.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              moment.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ir al módulo',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
