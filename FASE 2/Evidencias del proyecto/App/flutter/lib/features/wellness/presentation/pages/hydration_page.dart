import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mi_refugio_app/shared/constants/app_gradients.dart';
import 'package:mi_refugio_app/shared/constants/app_shadows.dart';
import 'package:mi_refugio_app/shared/data/hydration_guidelines.dart';

class HydrationPage extends StatelessWidget {
  const HydrationPage({super.key});

  static const _weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const _weeklyIntake = [1.6, 1.8, 2.0, 1.9, 2.1, 1.7, 1.8];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.softBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Hidratación'),
          actions: [
            IconButton(
              tooltip: 'Configurar recordatorios',
              onPressed: () {},
              icon: const Icon(Icons.alarm_add_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Container(
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
                            'Meta diaria sugerida por MINSAL: 2 litros. ¡Te faltan 600 ml para cumplirla!',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.local_drink_rounded,
                              size: 18,
                            ),
                            label: const Text('Registrar vaso de 250 ml'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _HydrationChart(intake: _weeklyIntake, labels: _weekdays),
              const SizedBox(height: 24),
              Text('Consejos respaldados', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              ...hydrationRecommendations.map(
                (tip) => _HydrationTipCard(tip: tip),
              ),
              const SizedBox(height: 24),
              Text('Fuentes validadas', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              _SourceCard(
                title: 'Ministerio de Salud de Chile',
                subtitle:
                    'Guía de hidratación saludable 2024 · Elige Vivir Sano',
                asset: 'assets/images/government/gobierno_chile.png',
                link: 'https://eligevivirsano.cl/',
              ),
              const SizedBox(height: 12),
              _SourceCard(
                title: 'Colegio de Nutricionistas',
                subtitle:
                    'Recomendaciones sobre hidratación y consumo de infusiones',
                asset: 'assets/images/government/gobierno_chile.png',
                link: 'https://www.colegionutricionistas.cl/',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HydrationChart extends StatelessWidget {
  const _HydrationChart({required this.intake, required this.labels});

  final List<double> intake;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = [
      for (int i = 0; i < intake.length; i++) FlSpot(i.toDouble(), intake[i]),
    ];
    final maxY = intake.reduce((a, b) => a > b ? a : b);
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
          Row(
            children: [
              Text('Registro semanal', style: theme.textTheme.titleMedium),
              const Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text('Objetivo: 2 L'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY + 0.4,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) =>
                          Text('${value.toStringAsFixed(1)} L'),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        return index >= 0 && index < labels.length
                            ? Text(labels[index])
                            : const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.12),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF3A84FF),
                    barWidth: 4,
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
                      getDotPainter: (_spot, _percent, _bar, _index) =>
                          FlDotCirclePainter(
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
            onPressed: () {
              // TODO: Integrar launcher externo.
            },
            icon: const Icon(Icons.open_in_new_rounded),
          ),
        ],
      ),
    );
  }
}
