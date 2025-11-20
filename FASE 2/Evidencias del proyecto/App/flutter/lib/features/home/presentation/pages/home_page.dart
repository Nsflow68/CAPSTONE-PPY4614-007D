import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_gradients.dart';
import '../../../../shared/constants/emotion_palette.dart';
import '../../../../shared/constants/app_shadows.dart';
import '../../../../shared/data/hydration_guidelines.dart';
import '../../../../shared/models/hydration_daily_intake.dart';
import '../../../../shared/utils/responsive_layout.dart';
import '../../../onboarding/presentation/widgets/user_journey_banner.dart';
import '../../../rewards/application/reward_provider.dart';
import '../../../rewards/application/reward_state.dart';
import '../../../rewards/presentation/widgets/reward_tile.dart';
import '../../../wellness/application/hydration_providers.dart';
import '../../../diary/application/diary_highlights_provider.dart';
import '../../application/home_mood_provider.dart';

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
    final layout = ResponsiveLayout.of(context);
    final moodHighlight = ref.watch(homeMoodProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.softBackground),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: layout.horizontalPadding,
                    ),
                    child: _HomeHeader(
                      highlight: moodHighlight,
                      onGuideTap: () => context.go('/guide'),
                      onDiaryTap: () => context.go('/diary'),
                      onRewardsTap: () => context.go('/home/rewards'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 12,
                      bottom: 8,
                      left: layout.horizontalPadding,
                      right: layout.horizontalPadding,
                    ),
                    child: const _EmotionCarousel(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: layout.horizontalPadding,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        UserJourneyBanner(
                          highlight:
                              'Descubre cómo usar Inicio, Diario, Chatbot y Perfil con recomendaciones personalizadas.',
                          onOpenGuide: () => context.go('/guide'),
                        ),
                        const SizedBox(height: 16),
                        _DailyEmotionCard(
                          highlight: moodHighlight,
                          onRegister: () => context.go('/diary/entry/new'),
                          onViewHistory: () => context.go('/diary'),
                        ),
                        const SizedBox(height: 16),
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
                        _HydrationSection(
                          hydrationSummary: hydrationSummary,
                          onViewDetails: () => context.go('/home/hydration'),
                          onRefresh: () => ref.invalidate(hydrationSummaryProvider),
                        ),
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
        ),
      ),
    );
  }


}


class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.highlight,
    required this.onGuideTap,
    required this.onDiaryTap,
    required this.onRewardsTap,
  });

  final HomeMoodHighlight highlight;
  final VoidCallback onGuideTap;
  final VoidCallback onDiaryTap;
  final VoidCallback onRewardsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 340,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: highlight.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
        boxShadow: AppShadows.soft,
      ),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        highlight.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        highlight.subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onGuideTap,
                  icon: const Icon(Icons.auto_stories_rounded, color: Colors.white),
                  tooltip: 'Guía interactiva',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Plan de bienestar diario',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Activa recordatorios, revisa emociones recientes y continúa tu rutina.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatChip(label: highlight.scoreLabel, icon: Icons.favorite_rounded),
              _StatChip(label: highlight.dateLabel, icon: Icons.calendar_month_rounded),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onDiaryTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: Text(highlight.hasEntry ? 'Registrar otra' : 'Registrar emoción'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onRewardsTap,
                  icon: const Icon(Icons.emoji_events_rounded),
                  label: const Text('Ver logros'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DailyEmotionCard extends StatelessWidget {
  const _DailyEmotionCard({
    required this.highlight,
    required this.onRegister,
    required this.onViewHistory,
  });

  final HomeMoodHighlight highlight;
  final VoidCallback onRegister;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            highlight.gradient.first.withValues(alpha: 0.12),
            highlight.gradient.last.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: highlight.gradient.last.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Text(
                  highlight.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      highlight.hasEntry
                          ? 'Última emoción registrada'
                          : 'Registra tu emoción de hoy',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      highlight.scoreLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (highlight.emotions.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: highlight.emotions
                  .take(4)
                  .map(
                    (emotion) => Chip(
                      label: Text(emotion),
                      backgroundColor: Colors.white,
                      labelStyle: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            Text(
              'Comienza con una nota breve para ver tus logros diarios.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onRegister,
                  child: Text(highlight.hasEntry ? 'Registrar otra' : 'Registrar emoción'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: onViewHistory,
                child: const Text('Ver historial'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _EmotionCarousel extends ConsumerStatefulWidget {
  const _EmotionCarousel();

  @override
  ConsumerState<_EmotionCarousel> createState() => _EmotionCarouselState();
}

class _EmotionCarouselState extends ConsumerState<_EmotionCarousel> {
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
    final diaryHighlights = ref.watch(diaryHighlightsProvider);
    final hasHighlights = diaryHighlights.isNotEmpty;
    final totalItems =
        hasHighlights ? diaryHighlights.length : EmotionPalette.cards.length;
    return SizedBox(
      height: 240,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              itemCount: totalItems,
              itemBuilder: (context, index) {
                final isActive = index == _current;
                return AnimatedScale(
                  duration: const Duration(milliseconds: 350),
                  scale: isActive ? 1 : 0.94,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: isActive ? 1 : 0.7,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: hasHighlights
                          ? _DiaryHighlightCard(
                              highlight: diaryHighlights[index],
                              onOpenDiary: () => context.go('/diary'),
                            )
                          : _EmotionPaletteCard(
                              entry: EmotionPalette.cards[index],
                              onExplore: () => context.go('/home/mindfulness'),
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
              totalItems,
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

class _EmotionPaletteCard extends StatelessWidget {
  const _EmotionPaletteCard({required this.entry, required this.onExplore});

  final EmotionPaletteEntry entry;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: entry.gradient,
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
            '${entry.emoji}  ${entry.title}',
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
                entry.subtitle,
                key: ValueKey(entry.subtitle),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ),
          ),
          FilledButton(
            onPressed: onExplore,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Explorar ejercicios'),
          ),
        ],
      ),
    );
  }
}

class _DiaryHighlightCard extends StatelessWidget {
  const _DiaryHighlightCard({
    required this.highlight,
    required this.onOpenDiary,
  });

  final DiaryHighlight highlight;
  final VoidCallback onOpenDiary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = _moodColorForScore(highlight.score);
    final gradient = _highlightGradient(baseColor);
    final dateLabel = DateFormat('EEE d MMM', 'es').format(highlight.date);
    final emotions = highlight.emotions.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
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
            dateLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            highlight.mood,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              highlight.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MoodScorePill(
                score: highlight.score,
                delta: highlight.scoreDelta,
              ),
              const Spacer(),
              FilledButton(
                onPressed: onOpenDiary,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ver diario'),
              ),
            ],
          ),
          if (emotions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: emotions
                  .map((emotion) => _EmotionChip(label: emotion))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodScorePill extends StatelessWidget {
  const _MoodScorePill({required this.score, required this.delta});

  final int score;
  final int delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deltaColor = _trendColor(delta);
    final deltaIcon = delta == 0
        ? Icons.horizontal_rule_rounded
        : delta > 0
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded;
    final deltaLabel =
        delta == 0 ? 'Sin cambio' : '${delta > 0 ? '+' : ''}$delta pts';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_rounded, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            '$score / 10',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Icon(deltaIcon, color: deltaColor, size: 18),
          const SizedBox(width: 4),
          Text(
            deltaLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: deltaColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionChip extends StatelessWidget {
  const _EmotionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

Color _moodColorForScore(int score) {
  if (score <= 2) return AppColors.danger;
  if (score <= 4) return AppColors.warning;
  if (score <= 7) return AppColors.moodCalm;
  if (score <= 8) return AppColors.moodJoy;
  return AppColors.success;
}

List<Color> _highlightGradient(Color base) {
  final hsl = HSLColor.fromColor(base);
  final start = hsl
      .withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0))
      .toColor()
      .withValues(alpha: 0.95);
  final end = hsl
      .withLightness((hsl.lightness - 0.05).clamp(0.0, 1.0))
      .toColor()
      .withValues(alpha: 0.85);
  return [start, end];
}

Color _trendColor(int delta) {
  if (delta > 0) {
    return Colors.greenAccent.shade100;
  }
  if (delta < 0) {
    return Colors.redAccent.shade100;
  }
  return Colors.white.withValues(alpha: 0.9);
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

class _HydrationSection extends StatelessWidget {
  const _HydrationSection({
    required this.hydrationSummary,
    required this.onViewDetails,
    required this.onRefresh,
  });

  final AsyncValue<List<HydrationDailyIntake>> hydrationSummary;
  final VoidCallback onViewDetails;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return hydrationSummary.when(
      data: (entries) => _HydrationContent(
        entries: entries,
        onViewDetails: onViewDetails,
      ),
      loading: () => const _HydrationPlaceholder(isLoading: true),
      error: (error, __) => _HydrationPlaceholder(
        message: 'No pudimos sincronizar tus datos, intenta nuevamente.',
        onRetry: onRefresh,
      ),
    );
  }
}

class _HydrationContent extends StatelessWidget {
  const _HydrationContent({
    required this.entries,
    required this.onViewDetails,
  });

  final List<HydrationDailyIntake> entries;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = ResponsiveLayout.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final todayEntry = entries.firstWhere(
      (entry) => DateUtils.isSameDay(entry.date, today),
      orElse: () => HydrationDailyIntake(
        date: today,
        goalMl: 2000,
      ),
    );
    final goalMl = todayEntry.goalMl ?? 2000;
    final consumedMl = todayEntry.totalMl;
    final goalLiters = goalMl / 1000;
    final consumedLiters = (consumedMl / 1000).clamp(0.0, 99.0);
    final remainingMl = goalMl - consumedMl;
    final remainingLiters = remainingMl <= 0 ? 0 : remainingMl / 1000;
    final completedDays =
        entries.where((entry) => entry.goalMl != null && entry.progress >= 1).length;
    final progress = goalMl == 0 ? 0.0 : (consumedMl / goalMl).clamp(0.0, 1.2);
    final hasEntries = entries.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.isExpanded ? 28 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFCDEBFF), Color(0xFFE7E0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hidratación semanal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hoy llevas ${consumedLiters.toStringAsFixed(1)} L de ${goalLiters.toStringAsFixed(1)} L.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Container(
                height: layout.isCompact ? 82 : 96,
                width: layout.isCompact ? 82 : 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/mascot/pose4.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.35),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).clamp(0, 120).toStringAsFixed(0)}% del objetivo diario cubierto',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HydrationMetricChip(
                icon: Icons.flag_rounded,
                label: 'Meta ${goalLiters.toStringAsFixed(1)} L',
              ),
              _HydrationMetricChip(
                icon: Icons.water_drop_rounded,
                label: remainingLiters <= 0
                    ? 'Meta cumplida ?'
                    : 'Faltan ${remainingLiters.toStringAsFixed(1)} L',
              ),
              _HydrationMetricChip(
                icon: Icons.star_rounded,
                label: '$completedDays/7 días al día',
              ),
            ],
          ),
          if (hasEntries) ...[
            const SizedBox(height: 22),
            _HydrationBar(entries: entries),
          ] else ...[
            const SizedBox(height: 18),
            Text(
              'Aún no registras ingestas esta semana. Ve al módulo para comenzar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onViewDetails,
              label: const Text('Abrir registro de hidratación'),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationBar extends StatelessWidget {
  const _HydrationBar({required this.entries});

  final List<HydrationDailyIntake> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final ordered = List<HydrationDailyIntake>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    var maxGoal = 0.0;
    for (final entry in ordered) {
      final goal = entry.goalMl ?? 0;
      if (goal > maxGoal) {
        maxGoal = goal;
      }
      if (entry.totalMl > maxGoal) {
        maxGoal = entry.totalMl;
      }
    }
    maxGoal = maxGoal == 0 ? 2000 : maxGoal;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final entry in ordered)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 88,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        width: 16,
                        height: (entry.totalMl / maxGoal).clamp(0.0, 1.0) * 88,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          gradient: LinearGradient(
                            colors: [Color(0xFF6F8BFF), Color(0xFF50E3FF)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _shortLabel(entry.dateLabel),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: AppColors.textPrimary.withValues(alpha: 0.75),
                    ),
                  ),
                  Text(
                    '${(entry.totalMl / 1000).toStringAsFixed(1)} L',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static String _shortLabel(String label) {
    if (label.length <= 2) {
      return label.toUpperCase();
    }
    return label.substring(0, 2).toUpperCase();
  }
}

class _HydrationPlaceholder extends StatelessWidget {
  const _HydrationPlaceholder({this.isLoading = false, this.message, this.onRetry});

  final bool isLoading;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : const Icon(
                      Icons.water_drop_rounded,
                      color: AppColors.primary,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoading
                      ? 'Sincronizando tu rutina de agua...'
                      : (message ?? 'Consulta tu progreso de hidratación aquí.'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isLoading
                      ? 'Ajustando recomendaciones según tu actividad.'
                      : 'Valida tu conexión y vuelve a intentar si el problema persiste.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isLoading && onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _HydrationMetricChip extends StatelessWidget {
  const _HydrationMetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
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
    final layout = ResponsiveLayout.of(context);
    final cards = [
      _HabitCardData(
        title: 'Mindfulness',
        subtitle: 'Respira, medita y mu?vete consciente.',
        gradient: const [Color(0xFF9478FF), Color(0xFFB59BFF)],
        asset: 'assets/images/mascot/pose2.png',
        onTap: onMindfulness,
      ),
      _HabitCardData(
        title: 'Alimentaci?n',
        subtitle: 'Monitorea macros y descubre recetas.',
        gradient: const [Color(0xFFFFD3E3), Color(0xFFF9E7CE)],
        asset: 'assets/images/mascot/pose3.png',
        onTap: onResources,
      ),
      _HabitCardData(
        title: 'Hidrataci?n',
        subtitle: 'Mantente al d?a con tu ingesta de agua.',
        gradient: const [Color(0xFFC6F4FF), Color(0xFFE2F1FF)],
        asset: 'assets/images/mascot/pose4.png',
        onTap: onHydration,
        fullWidth: true,
      ),
      _HabitCardData(
        title: 'ChatBot Refu',
        subtitle: 'Acompa?amiento emocional en cualquier momento.',
        gradient: const [Color(0xFFE1DBFF), Color(0xFFECD6FF)],
        asset: 'assets/images/mascot/pose1.png',
        onTap: onChatbot,
      ),
      _HabitCardData(
        title: 'Diario emocional',
        subtitle: 'Registra tus emociones y acompa?a tu progreso.',
        gradient: const [Color(0xFFEFF3FF), Color(0xFFFDECF4)],
        asset: 'assets/images/branding/logo_primary.png',
        onTap: onDiary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'H?bitos clave',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final halfWidth = layout.isCompact ? maxWidth : (maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: card.fullWidth ? maxWidth : halfWidth,
                    child: _HabitCard(data: card),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _MentalHealthCard(onTap: onResources),
      ],
    );
  }
}

class _HabitCardData {
  _HabitCardData({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.asset,
    required this.onTap,
    this.fullWidth = false,
  });

  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String asset;
  final VoidCallback onTap;
  final bool fullWidth;
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({required this.data});

  final _HabitCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: data.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                data.asset,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MentalHealthCard extends StatelessWidget {
  const _MentalHealthCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/government/gobierno_chile.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gobierno de Chile',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Directorio actualizado de l?neas de ayuda y profesionales acreditados.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.open_in_new_rounded, color: AppColors.primary),
            ),
          ],
        ),
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










