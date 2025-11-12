import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_gradients.dart';
import '../../../../shared/constants/emotion_palette.dart';
import '../../../../shared/constants/app_shadows.dart';
import '../../../../shared/data/hydration_guidelines.dart';
import '../../../../shared/models/hydration_daily_intake.dart';
import '../../../rewards/application/reward_provider.dart';
import '../../../rewards/application/reward_state.dart';
import '../../../rewards/presentation/widgets/reward_tile.dart';
import '../../../wellness/application/hydration_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(rewardProvider.notifier).loadRewards());
  }

  @override
  Widget build(BuildContext context) {
    final rewardState = ref.watch(rewardProvider);
    final hydrationSummary = ref.watch(hydrationSummaryProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.softBackground),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(
                onGuideTap: () => context.go('/guide'),
                onRewardsTap: () => context.go('/home/rewards'),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 12, bottom: 8),
                child: _EmotionCarousel(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _RewardSection(
                      state: rewardState,
                      onViewAll: () => context.go('/home/rewards'),
                    ),
                    const SizedBox(height: 20),
                    _QuickActions(
                      onHydration: () => context.go('/home/hydration'),
                      onMindfulness: () => context.go('/home/mindfulness'),
                      onResources: () => context.go('/home/resources'),
                      onDiary: () => context.go('/diary'),
                      onChatbot: () => context.go('/chatbot'),
                    ),
                    const SizedBox(height: 24),
                    _HydrationSection(hydrationSummary: hydrationSummary),
                    const SizedBox(height: 24),
                    const _WellnessGuides(),
                    const SizedBox(height: 36),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onGuideTap, required this.onRewardsTap});

  final VoidCallback onGuideTap;
  final VoidCallback onRewardsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          height: 320,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7F79F9), Color(0xFF8BE1D0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          right: -40,
          top: 30,
          child: Transform.rotate(
            angle: -0.2,
            child: Container(
              width: 220,
              height: 260,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.16),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(42),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
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
                          'Mi Refugio',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Acompañamiento emocional y hábitos saludables.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onGuideTap,
                    icon: const Icon(Icons.help_rounded, color: Colors.white),
                    tooltip: 'Guía rápida',
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 18,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sigue tu plan de cuidado',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Registra tus hábitos, revisa recursos y gana recompensas por cada avance.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: onRewardsTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.emoji_events_rounded),
                      label: const Text('Ver mis logros'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmotionCarousel extends StatefulWidget {
  const _EmotionCarousel();

  @override
  State<_EmotionCarousel> createState() => _EmotionCarouselState();
}

class _EmotionCarouselState extends State<_EmotionCarousel> {
  final _controller = PageController(viewportFraction: 0.78);
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (page != _current && mounted) {
        setState(() => _current = page);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 240,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              itemCount: EmotionPalette.cards.length,
              itemBuilder: (context, index) {
                final card = EmotionPalette.cards[index];
                final isActive = index == _current;
                return AnimatedScale(
                  duration: const Duration(milliseconds: 350),
                  scale: isActive ? 1 : 0.94,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: isActive ? 1 : 0.7,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: card.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: AppShadows.soft,
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${card.emoji}  ${card.title}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  card.subtitle,
                                  key: ValueKey(card.subtitle),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Explorar ejercicios'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              EmotionPalette.cards.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: index == _current ? 28 : 10,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index == _current
                      ? AppColors.primary.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardSection extends StatelessWidget {
  const _RewardSection({required this.state, required this.onViewAll});

  final RewardState state;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recompensas destacadas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(onPressed: onViewAll, child: const Text('Ver todo')),
          ],
        ),
        const SizedBox(height: 14),
        state.when(
          initial: () => const _RewardPlaceholder(),
          loading: () => const _RewardPlaceholder(),
          error: (message) =>
              _RewardError(message: message, onRetry: onViewAll),
          loaded: (summary) {
            final rewards = summary.items;
            if (rewards.isEmpty) {
              return _RewardError(
                message: 'Aún no hay recompensas configuradas.',
                onRetry: onViewAll,
              );
            }

            final highlight = rewards.firstWhere(
              (reward) => reward.active,
              orElse: () => rewards.first,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Balance disponible: ${summary.balance} pts',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RewardTile(
                  reward: highlight,
                  balance: summary.balance,
                  highlight: true,
                  onTap: onViewAll,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RewardPlaceholder extends StatelessWidget {
  const _RewardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _RewardError extends StatelessWidget {
  const _RewardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Actualizar')),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onHydration,
    required this.onMindfulness,
    required this.onResources,
    required this.onDiary,
    required this.onChatbot,
  });

  final VoidCallback onHydration;
  final VoidCallback onMindfulness;
  final VoidCallback onResources;
  final VoidCallback onDiary;
  final VoidCallback onChatbot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tus módulos',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _ModuleCard(
              title: 'Hidratación',
              subtitle: 'Registra tu consumo diario y recibe alertas.',
              gradient: const LinearGradient(
                colors: [Color(0xFFDEF6FA), Color(0xFFE6E3FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              icon: Icons.water_drop_rounded,
              onTap: onHydration,
            ),
            _ModuleCard(
              title: 'Mindfulness',
              subtitle: 'Sesiones guiadas y favoritos personalizados.',
              gradient: const LinearGradient(
                colors: [Color(0xFFFDE9F5), Color(0xFFE2F4FB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              icon: Icons.self_improvement_rounded,
              onTap: onMindfulness,
            ),
            _ModuleCard(
              title: 'Recursos',
              subtitle: 'Centros de apoyo y material validado.',
              gradient: const LinearGradient(
                colors: [Color(0xFFFEEFD7), Color(0xFFEAF6E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              icon: Icons.handshake_rounded,
              onTap: onResources,
            ),
            _ModuleCard(
              title: 'Diario emocional',
              subtitle: 'Registra cómo te sientes y detecta patrones.',
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF3FF), Color(0xFFF7EBFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              icon: Icons.menu_book_rounded,
              onTap: onDiary,
            ),
            _ModuleCard(
              title: 'Habla con Refu',
              subtitle: 'Tu compañero de bienestar emocional.',
              gradient: const LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFFFF9C4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              icon: Icons.chat_bubble_rounded,
              onTap: onChatbot,
            ),
          ],
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Gradient gradient;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final width = size.width > 720
        ? (size.width - 56) / 3
        : (size.width - 60) / 2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width.clamp(0, size.width),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HydrationSection extends StatelessWidget {
  const _HydrationSection({required this.hydrationSummary});

  final AsyncValue<List<HydrationDailyIntake>> hydrationSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visión rápida de hidratación',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        hydrationSummary.when(
          data: (items) => _HydrationChart(items: items),
          loading: () => Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.soft,
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => const _HydrationError(
            message: 'No pudimos cargar tu resumen de hidratación',
          ),
        ),
      ],
    );
  }
}

class _HydrationChart extends StatelessWidget {
  const _HydrationChart({required this.items});

  final List<HydrationDailyIntake> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return const _HydrationError(
        message: 'Registra tu primera ingesta y verás tu progreso aquí.',
      );
    }

    final spots = items
        .asMap()
        .entries
        .map(
          (entry) =>
              FlSpot(entry.key.toDouble(), entry.value.totalMl.toDouble()),
        )
        .toList();

    final minY = spots.map((spot) => spot.y).reduce(math.min);
    final maxY = spots.map((spot) => spot.y).reduce(math.max);
    final goal = items.first.goalMl ?? 2000;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ãšltimos 7 días',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Meta diaria: ${goal.toInt()} ml',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: math.max(0, minY - 200),
                maxY: maxY + 200,
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 44,
                      showTitles: true,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index >= 0 && index < items.length) {
                          final date = items[index].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawHorizontalLine: true,
                  horizontalInterval: 250,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.textSecondary.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.25),
                          AppColors.primary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

class _HydrationError extends StatelessWidget {
  const _HydrationError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _WellnessGuides extends StatelessWidget {
  const _WellnessGuides();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips rápidos',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: hydrationRecommendations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final tip = hydrationRecommendations[index];
              return Container(
                width: 220,
                height: 160,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tip.icon,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tip.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        tip.detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
