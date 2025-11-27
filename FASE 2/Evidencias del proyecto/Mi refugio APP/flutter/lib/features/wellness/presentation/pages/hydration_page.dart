import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/constants/app_gradients.dart';
import '../../../../shared/constants/app_shadows.dart';
import '../../../../shared/data/hydration_guidelines.dart';
import '../../../../shared/models/hydration_daily_intake.dart';
import '../../../rewards/application/reward_provider.dart';
import '../../application/hydration_providers.dart';
import '../../data/hydration_repository.dart';

class HydrationPage extends ConsumerWidget {
  const HydrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(hydrationSummaryProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.softBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Hidratación'),
          actions: [
            IconButton(
              tooltip: 'Configurar recordatorios',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Pronto podrás programar recordatorios inteligentes desde aquí.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.alarm_add_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(hydrationSummaryProvider);
              await ref.read(hydrationSummaryProvider.future);
            },
            child: summaryAsync.when(
              data: (entries) => _HydrationContent(
                entries: entries,
                onRegisterIntake: () =>
                    _showRegisterIntakeSheet(context, ref),
              ),
              loading: () => const _HydrationLoading(),
              error: (error, __) => _HydrationError(
                message: error.toString(),
                onRetry: () => ref.invalidate(hydrationSummaryProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HydrationContent extends StatelessWidget {
  const _HydrationContent({
    required this.entries,
    required this.onRegisterIntake,
  });

  final List<HydrationDailyIntake> entries;
  final VoidCallback onRegisterIntake;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final todayData = entries.firstWhere(
      (entry) => DateUtils.isSameDay(entry.date, today),
      orElse: () => HydrationDailyIntake(date: today),
    );
    final goalMl = todayData.goalMl ?? 2000.0;
    final consumedMl = todayData.totalMl;
    final remainingMl = math.max(0.0, goalMl - consumedMl);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _HydrationHero(
          goalMl: goalMl,
          consumedMl: consumedMl,
          remainingMl: remainingMl,
          onRegisterIntake: onRegisterIntake,
        ),
        const SizedBox(height: 22),
        if (entries.isEmpty)
          _EmptyHydrationChart(theme: theme, onRegister: onRegisterIntake)
        else
          _HydrationChart(entries: entries),
        const SizedBox(height: 24),
        Text('Consejos respaldados', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final tip in hydrationRecommendations)
          _HydrationTipCard(tip: tip),
        const SizedBox(height: 24),
        Text('Fuentes validadas', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        const _SourceCard(
          title: 'Ministerio de Salud de Chile',
          subtitle: 'Guía de hidratación saludable 2024 · Elige Vivir Sano',
          asset: 'assets/images/government/gobierno_chile.png',
          link: 'https://eligevivirsano.cl/',
        ),
        const SizedBox(height: 12),
        const _SourceCard(
          title: 'Colegio de Nutricionistas',
          subtitle:
              'Recomendaciones sobre hidratación y consumo de infusiones',
          asset: 'assets/images/government/gobierno_chile.png',
          link: 'https://www.colegionutricionistas.cl/',
        ),
      ],
    );
  }
}

class _HydrationHero extends StatelessWidget {
  const _HydrationHero({
    required this.goalMl,
    required this.consumedMl,
    required this.remainingMl,
    required this.onRegisterIntake,
  });

  final double goalMl;
  final double consumedMl;
  final double remainingMl;
  final VoidCallback onRegisterIntake;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalLiters = goalMl / 1000;
    final consumedLiters = consumedMl / 1000;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF3FF), Color(0xFFF3F7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Color(0xFF3A84FF),
              size: 36,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Programa Elige Vivir Sano',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Meta sugerida: ${goalLiters.toStringAsFixed(1)}L. '
                  '${remainingMl > 0 ? 'Te faltan ${(remainingMl / 1000).toStringAsFixed(1)}L para llegar.' : '¡Meta diaria alcanzada!'}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: onRegisterIntake,
                  icon: const Icon(Icons.local_drink_rounded, size: 18),
                  label: Text(
                    'Registrar vaso (acumulado ${consumedLiters.toStringAsFixed(1)}L)',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationChart extends StatelessWidget {
  const _HydrationChart({required this.entries});

  final List<HydrationDailyIntake> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedEntries = [...entries]
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (var index = 0; index < sortedEntries.length; index++) {
      final entry = sortedEntries[index];
      spots.add(FlSpot(index.toDouble(), entry.totalLiters));
    }
    final maxY = spots.isEmpty
        ? 2.5
        : math.max(
            2.5,
            spots.map((spot) => spot.y).reduce(math.max) + 0.4,
          );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial semanal',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.blueGrey.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(1),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= sortedEntries.length) {
                          return const SizedBox.shrink();
                        }
                        final entry = sortedEntries[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_weekdayLabel(entry.date)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 4,
                    color: const Color(0xFF3A84FF),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF3A84FF).withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFF3A84FF),
                        strokeColor: Colors.white,
                        strokeWidth: 2,
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

class _EmptyHydrationChart extends StatelessWidget {
  const _EmptyHydrationChart({
    required this.theme,
    required this.onRegister,
  });

  final ThemeData theme;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Icon(Icons.water_drop_outlined,
              size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 18),
          Text(
            'Registra tu primer vaso',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí verás tu progreso semanal de hidratación. Registra un vaso para comenzar.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRegister,
            child: const Text('Registrar ahora'),
          ),
        ],
      ),
    );
  }
}

class _HydrationLoading extends StatelessWidget {
  const _HydrationLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: const [
        _HydrationLoadingCard(height: 140),
        SizedBox(height: 22),
        _HydrationLoadingCard(height: 260),
        SizedBox(height: 24),
        _HydrationLoadingCard(height: 100),
        SizedBox(height: 12),
        _HydrationLoadingCard(height: 100),
      ],
    );
  }
}

class _HydrationLoadingCard extends StatelessWidget {
  const _HydrationLoadingCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _HydrationError extends StatelessWidget {
  const _HydrationError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      children: [
        Icon(Icons.report_problem_rounded,
            size: 52, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          'No pudimos cargar tus datos de hidratación',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }
}

class _HydrationTipCard extends StatelessWidget {
  const _HydrationTipCard({required this.tip});

  final HydrationTip tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tip.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(tip.detail, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.link,
  });

  final String title;
  final String subtitle;
  final String asset;
  final String link;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(asset, width: 56, height: 56, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Abrir fuente oficial',
            onPressed: () => _launchExternal(context, link),
            icon: const Icon(Icons.open_in_new_rounded),
          ),
        ],
      ),
    );
  }
}

Future<void> _showRegisterIntakeSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final result = await showModalBottomSheet<double>(
    context: context,
    builder: (context) => const _HydrationRegisterSheet(),
  );

  if (result == null) return;

  final repository = ref.read(hydrationRepositoryProvider);
  final summaryState = ref.read(hydrationSummaryProvider);
  final rewardNotifier = ref.read(rewardProvider.notifier);
  final today = DateUtils.dateOnly(DateTime.now());
  double previousTotal = 0;

  summaryState.whenData((entries) {
    final todayEntry = entries.firstWhere(
      (entry) => DateUtils.isSameDay(entry.date, today),
      orElse: () => HydrationDailyIntake(date: today),
    );
    previousTotal = todayEntry.totalMl;
  });

  try {
    final mlValue = result.round();
    await repository.registerIntake(date: today, ml: mlValue);
    final todayTotal = previousTotal + mlValue;

    try {
      await rewardNotifier.awardPoints(10);
      if (todayTotal >= 1200) {
        await rewardNotifier.awardPoints(120);
      }
    } catch (_) {
      // Si falla la asignación de recompensas no interrumpimos el flujo.
    }

    ref.invalidate(hydrationSummaryProvider);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Registraste ${(mlValue / 1000).toStringAsFixed(1)} L de agua'),
      ),
    );
  } catch (error) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text('No se pudo registrar la ingesta: $error'),
      ),
    );
  }
}

class _HydrationRegisterSheet extends StatefulWidget {
  const _HydrationRegisterSheet();

  @override
  State<_HydrationRegisterSheet> createState() =>
      _HydrationRegisterSheetState();
}

class _HydrationRegisterSheetState extends State<_HydrationRegisterSheet> {
  double _amount = 250;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registrar nueva ingesta',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Escoge la cantidad aproximada de agua que tomaste.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Slider(
            value: _amount,
            min: 150,
            max: 750,
            divisions: 4,
            label: '${_amount.toInt()} ml',
            onChanged: (value) => setState(() => _amount = value),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_amount),
            child: Text('Registrar ${_amount.toInt()} ml'),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchExternal(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enlace no válido')),
    );
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo abrir el enlace')),
    );
  }
}

String _weekdayLabel(DateTime date) {
  final formatter = DateFormat.E('es');
  final label = formatter.format(date);
  return label.isEmpty ? '' : label[0].toUpperCase();
}
