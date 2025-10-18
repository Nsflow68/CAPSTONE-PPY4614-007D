import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mr_app/core/widgets/animated_button.dart';
import 'package:mr_app/core/widgets/animated_card.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Mi Refugio',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Cómo te sientes hoy?',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ).animate()
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildEmotionCard(
                        context,
                        'Feliz',
                        PhosphorIcons.smiley,
                        Colors.amber,
                      ),
                      _buildEmotionCard(
                        context,
                        'Tranquilo',
                        PhosphorIcons.peace,
                        Colors.blue,
                      ),
                      _buildEmotionCard(
                        context,
                        'Ansioso',
                        PhosphorIcons.warning,
                        Colors.orange,
                      ),
                      _buildEmotionCard(
                        context,
                        'Triste',
                        PhosphorIcons.cloud,
                        Colors.grey,
                      ),
                    ].animate(interval: 100.ms).fadeIn().scale(),
                  ),
                  const SizedBox(height: 24),
                  AnimatedButton(
                    text: 'Iniciar Chat',
                    onPressed: () {},
                    width: double.infinity,
                    height: 56,
                  ),
                  const SizedBox(height: 16),
                  AnimatedCard(
                    child: ListTile(
                      leading: const Icon(PhosphorIcons.chartLineUp),
                      title: const Text('Tu progreso'),
                      subtitle: const Text('Ver estadísticas y ejercicios'),
                      trailing: const Icon(PhosphorIcons.caretRight),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(PhosphorIcons.plus),
      ).animate()
        .scale(delay: 500.ms)
        .shake(delay: 1500.ms),
    );
  }

  Widget _buildEmotionCard(
    BuildContext context,
    String emotion,
    IconData icon,
    Color color,
  ) {
    return AnimatedCard(
      onTap: () {},
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            emotion,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}