import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_gradients.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../application/diary_provider.dart';
import '../../data/models/diary_entry_model.dart';
import 'widgets/diary_empty_view.dart';

class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> with TickerProviderStateMixin {
  String _selectedMood = 'Todos';
  DateTimeRange? _selectedRange;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    
    scheduleMicrotask(() {
      ref.read(diaryProvider.notifier).loadEntries();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _reload() {
    return ref
        .read(diaryProvider.notifier)
        .loadEntries(from: _selectedRange?.start, to: _selectedRange?.end);
  }

  Future<void> _openRangePicker() async {
    final now = DateTime.now();
    final initialRange =
        _selectedRange ??
        DateTimeRange(
          start: DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 6)),
          end: DateTime(now.year, now.month, now.day),
        );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      helpText: 'Selecciona el rango',
      saveText: 'Aplicar',
    );

    if (picked != null) {
      setState(() => _selectedRange = picked);
      await _reload();
    }
  }

  void _openCreateEntry() {
    context.push('/diary/entry/new');
  }

  void _clearFilters() {
    setState(() {
      _selectedRange = null;
      _selectedMood = 'Todos';
    });
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diario emocional'),
        actions: [
          IconButton(
            tooltip: 'Restablecer filtros',
            onPressed: (_selectedRange != null || _selectedMood != 'Todos')
                ? _clearFilters
                : null,
            icon: const Icon(Icons.filter_alt_off_outlined),
          ),
          IconButton(
            tooltip: 'Filtrar por fecha',
            onPressed: _openRangePicker,
            icon: const Icon(Icons.calendar_today_outlined),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: _openCreateEntry,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Nueva entrada'),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: state.map(
              initial: (_) => const _DiaryLoading(),
              loading: (_) => const _DiaryLoading(),
              loaded: (data) => _DiaryLoadedView(
                key: ValueKey(data.entries.length + data.entries.hashCode),
                entries: data.entries,
                selectedMood: _selectedMood,
                onMoodSelected: (value) => setState(() => _selectedMood = value),
                onRefresh: _reload,
                onCreate: _openCreateEntry,
                onOpenRange: _openRangePicker,
                range: _selectedRange,
              ),
              empty: (_) => DiaryEmptyView(onCreate: _openCreateEntry),
              error: (failure) => DiaryErrorView(
                message: failure.failure.readableMessage(),
                onRetry: _reload,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiaryLoadedView extends StatelessWidget {
  const _DiaryLoadedView({
    super.key,
    required this.entries,
    required this.selectedMood,
    required this.onMoodSelected,
    required this.onRefresh,
    required this.onCreate,
    required this.onOpenRange,
    required this.range,
  });

  final List<DiaryEntryModel> entries;
  final String selectedMood;
  final ValueChanged<String> onMoodSelected;
  final Future<void> Function() onRefresh;
  final VoidCallback onCreate;
  final VoidCallback onOpenRange;
  final DateTimeRange? range;

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));

    final moodSet =
        sorted
            .map((entry) => entry.mood.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final filters = ['Todos', ...moodSet];
    final effectiveMood = filters.contains(selectedMood)
        ? selectedMood
        : 'Todos';

    final filtered = effectiveMood == 'Todos'
        ? sorted
        : sorted
              .where(
                (entry) =>
                    entry.mood.toLowerCase() == effectiveMood.toLowerCase(),
              )
              .toList();

    final summary = _DiarySummaryData.fromEntries(sorted);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          _DiaryHeader(
            summary: summary,
            range: range,
            onOpenRange: onOpenRange,
          ),
          const SizedBox(height: 24),
          _MoodFilters(
            filters: filters,
            selected: effectiveMood,
            onSelected: onMoodSelected,
          ),
          const SizedBox(height: 24),
          if (filtered.isEmpty)
            _DiaryEmptyState(onCreate: onCreate)
          else
            ...filtered.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final diaryEntry = entry.value;
                return _AnimatedEntryCard(
                  delay: index * 100,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _DiaryEntryCard(entry: diaryEntry),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Animated Entry Card Wrapper
class _AnimatedEntryCard extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedEntryCard({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
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
      child: child,
    );
  }
}

class _DiarySummaryData {
  _DiarySummaryData({
    required this.total,
    required this.weekCount,
    required this.averageScore,
    required this.topMood,
    required this.topEmotions,
    required this.recentEntry,
  });

  final int total;
  final int weekCount;
  final double? averageScore;
  final String? topMood;
  final List<String> topEmotions;
  final DiaryEntryModel? recentEntry;

  factory _DiarySummaryData.fromEntries(List<DiaryEntryModel> entries) {
    if (entries.isEmpty) {
      return _DiarySummaryData(
        total: 0,
        weekCount: 0,
        averageScore: null,
        topMood: null,
        topEmotions: const [],
        recentEntry: null,
      );
    }

    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));

    final weekCount = entries
        .where((entry) => entry.date.isAfter(weekStart))
        .length;
    final avg =
        entries.fold<int>(0, (acc, entry) => acc + entry.score) /
        entries.length;

    final moodCounts = <String, int>{};
    for (final entry in entries) {
      final mood = entry.mood.trim();
      if (mood.isEmpty) continue;
      moodCounts.update(mood, (value) => value + 1, ifAbsent: () => 1);
    }

    final topMoodEntry = moodCounts.entries.isEmpty
        ? null
        : moodCounts.entries.reduce((a, b) => a.value >= b.value ? a : b);

    final emotionCounts = <String, int>{};
    for (final entry in entries) {
      for (final emotion in entry.emotions) {
        final value = emotion.trim();
        if (value.isEmpty) continue;
        emotionCounts.update(value, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    final topEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _DiarySummaryData(
      total: entries.length,
      weekCount: weekCount,
      averageScore: avg,
      topMood: topMoodEntry?.key,
      topEmotions: topEmotions.take(3).map((item) => item.key).toList(),
      recentEntry: entries.first,
    );
  }
}

class _DiaryHeader extends StatelessWidget {
  const _DiaryHeader({
    required this.summary,
    required this.range,
    required this.onOpenRange,
  });

  final _DiarySummaryData summary;
  final DateTimeRange? range;
  final VoidCallback onOpenRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rangeLabel = range == null
        ? 'Todo el historial'
        : '${DateFormat('d MMM', 'es').format(range!.start)} - ${DateFormat('d MMM', 'es').format(range!.end)}';

    final averageLabel = summary.averageScore == null
        ? 'Sin datos'
        : '${summary.averageScore!.toStringAsFixed(1)} / 10';

    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primaryBubble,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Resumen',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.date_range_outlined, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      rangeLabel,
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SummaryStatCompact(
                  icon: Icons.auto_graph_rounded,
                  label: 'Total',
                  value: summary.total.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryStatCompact(
                  icon: Icons.calendar_view_week_rounded,
                  label: 'Esta semana',
                  value: summary.weekCount.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryStatCompact(
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  label: 'Estado frecuente',
                  value: summary.topMood ?? 'N/A',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryStatCompact(
                  icon: Icons.favorite_rounded,
                  label: 'Promedio',
                  value: averageLabel,
                ),
              ),
            ],
          ),
          if (summary.topEmotions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Emociones frecuentes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: summary.topEmotions
                  .map(
                    (emotion) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        emotion,
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryStatCompact extends StatelessWidget {
  const _SummaryStatCompact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodFilters extends StatelessWidget {
  const _MoodFilters({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtra por estado emocional',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: filters
              .map(
                (mood) => ChoiceChip(
                  label: Text(mood),
                  selected: selected == mood,
                  onSelected: (_) => onSelected(mood),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DiaryEntryCard extends StatefulWidget {
  const _DiaryEntryCard({required this.entry});

  final DiaryEntryModel entry;

  @override
  State<_DiaryEntryCard> createState() => _DiaryEntryCardState();
}

class _DiaryEntryCardState extends State<_DiaryEntryCard> with SingleTickerProviderStateMixin {
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
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEE d MMM yyyy', 'es').format(widget.entry.date);
    final timeLabel = DateFormat('HH:mm', 'es').format(widget.entry.createdAt);
    final color = _moodColor(widget.entry.score);
    final emotionIcon = EmotionIcons.getEmotionIcon(widget.entry.mood);

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Emotion Icon
                    Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SvgPicture.asset(
                        emotionIcon,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.entry.mood.isEmpty ? 'Sin estado' : widget.entry.mood,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$dateLabel · $timeLabel',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${widget.entry.score}/10',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.entry.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.entry.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.78),
                    height: 1.5,
                  ),
                ),
                if (widget.entry.emotions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.entry.emotions
                        .take(4)
                        .map(
                          (emotion) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              emotion,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _moodColor(int score) {
    if (score <= 2) return AppColors.danger;
    if (score <= 4) return AppColors.warning;
    if (score <= 7) return AppColors.moodCalm;
    if (score <= 8) return AppColors.moodJoy;
    return AppColors.success;
  }
}

class _DiaryEmptyState extends StatelessWidget {
  const _DiaryEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aún no hay registros',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escribe tu primera entrada para comenzar a seguir tus emociones y progresos.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Registrar nueva entrada'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaryLoading extends StatelessWidget {
  const _DiaryLoading();

  @override
  Widget build(BuildContext context) {
    return const LoadingIndicator(
      message: 'Cargando entradas...',
    );
  }
}

class DiaryErrorView extends StatelessWidget {
  const DiaryErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
