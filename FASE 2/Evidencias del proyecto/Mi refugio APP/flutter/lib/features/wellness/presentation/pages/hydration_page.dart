import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../shared/constants/app_shadows.dart';
import '../../../../shared/data/hydration_guidelines.dart';
import '../../../../shared/models/hydration_daily_intake.dart';
import '../../../rewards/application/reward_provider.dart';
import '../../application/hydration_providers.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/hydration_repository.dart';

class HydrationPage extends ConsumerWidget {
  const HydrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(hydrationSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Pastel Blue Background
      appBar: AppBar(
        title: const Text('Hidratación'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotificationSettings(context),
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
              onRegisterIntake: () => _showRegisterIntakeSheet(context, ref),
            ),
            loading: () => const _HydrationLoading(),
            error: (error, __) => _HydrationError(
              message: error.toString(),
              onRetry: () => ref.invalidate(hydrationSummaryProvider),
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
    final progress = (consumedMl / goalMl).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _MascotHydrationHero(
          progress: progress,
          consumedMl: consumedMl,
          goalMl: goalMl,
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
      ],
    );
  }
}

class _MascotHydrationHero extends StatelessWidget {
  final double progress;
  final double consumedMl;
  final double goalMl;
  final VoidCallback onRegisterIntake;

  const _MascotHydrationHero({
    required this.progress,
    required this.consumedMl,
    required this.goalMl,
    required this.onRegisterIntake,
  });

  String get _mascotAsset {
    if (progress < 0.25) return 'assets/images/rewards/pose_1.svg';
    if (progress < 0.5) return 'assets/images/rewards/pose_2.svg';
    if (progress < 0.75) return 'assets/images/rewards/pose_3.svg';
    return 'assets/images/rewards/pose_4.svg';
  }

  String get _mascotMessage {
    if (progress < 0.25) return '¡Empecemos a hidratarnos!';
    if (progress < 0.5) return '¡Vas muy bien, sigue así!';
    if (progress < 0.75) return '¡Casi llegamos a la meta!';
    return '¡Excelente trabajo! 🎉';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _mascotMessage,
                        style: const TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(consumedMl / 1000).toStringAsFixed(1)}L',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    Text(
                      'de ${(goalMl / 1000).toStringAsFixed(1)}L meta diaria',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF2D3436).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 120,
                width: 120,
                child: SvgPicture.asset(_mascotAsset),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE3F2FD),
            color: const Color(0xFF2196F3),
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRegisterIntake,
              icon: const Icon(Icons.water_drop),
              label: const Text('Registrar vaso'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
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
                    color: Colors.blueGrey.withOpacity(0.08),
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
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                          child: Text(
                            _weekdayLabel(entry.date),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
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
                          const Color(0xFF3A84FF).withOpacity(0.18),
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
    return const Center(child: CircularProgressIndicator());
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
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

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Registrar nueva ingesta',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escoge la cantidad aproximada de agua que tomaste.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PresetButton(
                amount: 250,
                label: 'Vaso',
                isSelected: _amount == 250,
                onTap: () => setState(() => _amount = 250),
              ),
              _PresetButton(
                amount: 500,
                label: 'Botella',
                isSelected: _amount == 500,
                onTap: () => setState(() => _amount = 500),
              ),
              _PresetButton(
                amount: 750,
                label: 'Grande',
                isSelected: _amount == 750,
                onTap: () => setState(() => _amount = 750),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('150 ml', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
              Text(
                '${_amount.toInt()} ml',
                style: const TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text('750 ml', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF2196F3),
              inactiveTrackColor: const Color(0xFFE3F2FD),
              thumbColor: const Color(0xFF2196F3),
              overlayColor: const Color(0xFF2196F3).withOpacity(0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _amount,
              min: 150,
              max: 750,
              divisions: 12,
              onChanged: (value) => setState(() => _amount = value),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_amount),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Registrar ahora',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.amount,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final int amount;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.local_drink_rounded,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              '$amount ml',
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showNotificationSettings(BuildContext context) async {
  final time = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 10, minute: 0),
    helpText: 'Programar recordatorio diario',
  );

  if (time != null && context.mounted) {
    await NotificationService().scheduleDailyNotification(
      id: 1, // Unique ID for hydration
      title: '¡Hora de hidratarse!',
      body: 'Recuerda tomar un vaso de agua para mantenerte saludable.',
      time: time,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recordatorio programado para las ${time.format(context)}')),
    );
  }
}

String _weekdayLabel(DateTime date) {
  final formatter = DateFormat.E('es');
  final label = formatter.format(date);
  return label.isEmpty ? '' : label[0].toUpperCase();
}
