import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../application/diary_provider.dart';
import '../../data/models/diary_entry_model.dart';
import 'widgets/diary_empty_view.dart';

class DiaryPage extends ConsumerStatefulWidget {
  const DiaryPage({super.key});

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {
  String _selectedMood = 'Todos';
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      ref.read(diaryProvider.notifier).loadEntries();
    });
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateEntry,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva entrada'),
      ),
      body: SafeArea(
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
            ...filtered.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _DiaryEntryCard(entry: entry),
              ),
            ),
        ],
      ),
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
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.tertiary.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Resumen',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onOpenRange,
                icon: const Icon(Icons.date_range_outlined),
                label: Text(rangeLabel),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemWidth = width < 480 ? width : (width - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _SummaryStat(
                    icon: Icons.auto_graph_rounded,
                    label: 'Entradas totales',
                    value: summary.total.toString(),
                    width: itemWidth,
                  ),
                  _SummaryStat(
                    icon: Icons.calendar_view_week_rounded,
                    label: 'Ultimos 7 dias',
                    value: summary.weekCount.toString(),
                    width: itemWidth,
                  ),
                  _SummaryStat(
                    icon: Icons.sentiment_satisfied_alt_rounded,
                    label: 'Estado predominante',
                    value: summary.topMood ?? 'Sin registros',
                    width: itemWidth,
                  ),
                  _SummaryStat(
                    icon: Icons.favorite_rounded,
                    label: 'Promedio de bienestar',
                    value: averageLabel,
                    width: itemWidth,
                  ),
                ],
              );
            },
          ),
          if (summary.topEmotions.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'Emociones frecuentes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: summary.topEmotions
                  .map(
                    (emotion) => Chip(
                      label: Text(emotion),
                      backgroundColor: AppColors.surfaceAlt,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (summary.recentEntry != null) ...[
            const SizedBox(height: 18),
            Text(
              'Ultima entrada registrada',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _DiaryHighlight(entry: summary.recentEntry!),
          ],
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.width,
  });

  final IconData icon;
  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryHighlight extends StatelessWidget {
  const _DiaryHighlight({required this.entry});

  final DiaryEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('d MMM · HH:mm', 'es').format(entry.createdAt);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                dateLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                entry.mood.isEmpty ? 'Sin estado' : entry.mood,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
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
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
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

class _DiaryEntryCard extends StatelessWidget {
  const _DiaryEntryCard({required this.entry});

  final DiaryEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = DateFormat('EEE d MMM yyyy', 'es').format(entry.date);
    final timeLabel = DateFormat('HH:mm', 'es').format(entry.createdAt);
    final color = _moodColor(entry.score);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 12),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    entry.mood.isEmpty ? 'Sin estado' : entry.mood,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${entry.score}/10',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            if (entry.emotions.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.emotions
                    .take(4)
                    .map(
                      (emotion) => Chip(
                        label: Text(emotion),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.surfaceAlt,
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '$dateLabel · $timeLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  entry.moodText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
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
                color: AppColors.primary.withValues(alpha: 0.15),
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
              'Aun no hay registros',
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
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Error al cargar entradas',
      message: message,
      action: ElevatedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Reintentar'),
      ),
    );
  }
}
