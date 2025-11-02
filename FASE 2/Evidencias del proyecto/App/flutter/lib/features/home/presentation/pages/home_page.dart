import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';
import 'package:mi_refugio_app/shared/constants/app_gradients.dart';
import 'package:mi_refugio_app/shared/constants/app_shadows.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showWeek = true;
  static const _weekDays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const _months = [
    'E',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ];
  static const _emotionWeekData = [
    FlSpot(0, 3.2),
    FlSpot(1, 2.4),
    FlSpot(2, 2.8),
    FlSpot(3, 2.5),
    FlSpot(4, 3.4),
    FlSpot(5, 3.8),
    FlSpot(6, 4.2),
  ];
  static const _emotionYearData = [
    FlSpot(0, 2.5),
    FlSpot(1, 2.9),
    FlSpot(2, 3.1),
    FlSpot(3, 3.4),
    FlSpot(4, 3.0),
    FlSpot(5, 3.8),
    FlSpot(6, 4.1),
    FlSpot(7, 4.3),
    FlSpot(8, 3.9),
    FlSpot(9, 4.4),
    FlSpot(10, 4.1),
    FlSpot(11, 4.6),
  ];
  static const _govLogoUrl =
      'https://www.gob.cl/wp-content/uploads/2020/04/logo-gobierno-de-chile.png';
  void _togglePeriod(bool isWeek) {
    if (showWeek != isWeek) {
      setState(() => showWeek = isWeek);
    }
  }

  void _open(BuildContext context, String path) => context.go(path);
  LineChartData _buildEmotionTrendChartData() {
    final dataPoints = showWeek ? _emotionWeekData : _emotionYearData;
    final minY = dataPoints.map((spot) => spot.y).reduce(math.min);
    final maxY = dataPoints.map((spot) => spot.y).reduce(math.max);
    return LineChartData(
      minY: math.max(0, minY - 0.5),
      maxY: maxY + 0.5,
      clipData: const FlClipData.all(),
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.grey.withValues(alpha: 0.08), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (showWeek) {
                if (index >= 0 && index < _weekDays.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_weekDays[index]),
                  );
                }
              } else if (index >= 0 && index < _months.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_months[index]),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0)),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: dataPoints,
          isCurved: true,
          curveSmoothness: 0.42,
          color: AppColors.primary,
          barWidth: 4,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.35),
                AppColors.primary.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.softBackground),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 16),
                    _buildHeroCard(context, theme),
                    const SizedBox(height: 18),
                    _buildEmotionTrendCard(theme),
                    const SizedBox(height: 24),
                    Text('Hábitos clave', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _buildHabitsSection(context),
                    const SizedBox(height: 28),
                    Text(
                      'Ayuda de salud mental',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildResourcesCard(context, theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mi Refugio', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'Tu resumen emocional y hábitos saludables',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _open(context, '/home/resources'),
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Ver novedades',
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surface,
              child: Image.asset(
                'assets/images/mascot/pose4.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, ThemeData theme) {
    return Container(
      height: 185,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5F6CF4), Color(0xFF8690FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppShadows.soft,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -18,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/branding/logo_primary.png',
                height: 220,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estamos contigo',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registra tus emociones, practica mindfulness y descubre recursos validados para tu bienestar.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: () => _open(context, '/diary/entry/new'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text('Agregar nueva emoción'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 130,
                  child: Image.asset(
                    'assets/images/mascot/pose1.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionTrendCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Text('Emociones', style: theme.textTheme.titleLarge),
              const Spacer(),
              ChoiceChip(
                label: const Text('Semana'),
                selected: showWeek,
                onSelected: (_) => _togglePeriod(true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Año'),
                selected: !showWeek,
                onSelected: (_) => _togglePeriod(false),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: LineChart(
              _buildEmotionTrendChartData(),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatBadge(
                icon: Icons.task_alt_rounded,
                label: 'Racha activa',
                value: showWeek ? '7 d�as' : '22 d�as',
              ),
              _StatBadge(
                icon: Icons.favorite_rounded,
                label: 'Promedio de ánimo',
                value: showWeek ? '3.4 / 5' : '3.8 / 5',
              ),
              _StatBadge(
                icon: Icons.bolt_rounded,
                label: 'Sesiones guiadas',
                value: '14',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth >= 900
            ? 3
            : maxWidth >= 620
            ? 2
            : 1;
        final horizontalGaps = gap * (columns - 1);
        final rawWidth = columns == 1
            ? maxWidth
            : (maxWidth - horizontalGaps) / columns;
        final safeWidth = rawWidth <= 0 ? maxWidth : rawWidth;
        final cardWidth = columns == 1 ? safeWidth.clamp(0, 420) : safeWidth;
        final alignment = columns == 1
            ? WrapAlignment.center
            : WrapAlignment.start;
        return Align(
          alignment: columns == 1 ? Alignment.center : Alignment.centerLeft,
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            alignment: alignment,
            children: [
              _ModuleCard(
                title: 'Mindfulness',
                subtitle: 'Respira, medita y muévete consciente',
                gradient: AppGradients.cardPrimary,
                asset: 'assets/images/mascot/pose1.png',
                onTap: () => _open(context, '/home/mindfulness'),
                width: cardWidth.toDouble(),
              ),
              _ModuleCard(
                title: 'Alimentación',
                subtitle: 'Monitorea macros y descubre recetas',
                gradient: AppGradients.cardSecondary,
                asset: 'assets/images/mascot/pose2_b.png',
                onTap: () => _open(context, '/home/nutrition'),
                width: cardWidth.toDouble(),
              ),
              _ModuleCard(
                title: 'Hidratación',
                subtitle: 'Mantente al d�a con tu ingesta de agua',
                gradient: AppGradients.cardAccent,
                asset: 'assets/images/mascot/pose4.png',
                onTap: () => _open(context, '/home/hydration'),
                width: cardWidth.toDouble(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResourcesCard(BuildContext context, ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => _open(context, '/home/resources'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: AppGradients.cardAccent,
              ),
              child: Center(
                child: Image.network(
                  _govLogoUrl,
                  height: 42,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/branding/logo_primary.png',
                    height: 42,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gobierno de Chile', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Directorio actualizado de l�neas de ayuda y profesionales acreditados.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
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
    this.icon,
    this.asset,
    required this.onTap,
    this.width,
  }) : assert(icon != null || asset != null, 'Provide icon or asset');
  final String title;
  final String subtitle;
  final Gradient gradient;
  final IconData? icon;
  final String? asset;
  final VoidCallback onTap;
  final double? width;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardWidth =
        width ??
        () {
          final screenWidth = MediaQuery.of(context).size.width;
          final available = screenWidth > 720
              ? (screenWidth - 20 * 2 - 14 * 2) / 3
              : (screenWidth - 20 * 2 - 14) / 2;
          return available > 0 ? available : screenWidth;
        }();
    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppShadows.elevated,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: asset != null
                    ? Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(asset!, fit: BoxFit.contain),
                      )
                    : Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ver más',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
