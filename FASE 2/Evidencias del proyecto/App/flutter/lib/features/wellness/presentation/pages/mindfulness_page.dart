import 'package:flutter/material.dart';
import 'package:mi_refugio_app/shared/constants/app_gradients.dart';
import 'package:mi_refugio_app/shared/constants/app_shadows.dart';
import 'package:mi_refugio_app/shared/data/mindfulness_content.dart';

class MindfulnessPage extends StatelessWidget {
  const MindfulnessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.softBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Mindfulness'),
          actions: [
            IconButton(
              tooltip: 'Programar recomendaciones',
              onPressed: () {},
              icon: const Icon(Icons.auto_awesome_rounded),
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
                    colors: [Color(0xFFF2E9FF), Color(0xFFE8F3FF)],
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
                        Icons.self_improvement_rounded,
                        size: 36,
                        color: Color(0xFF7E6BC4),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recomendaciones chilenas',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Recursos validados por MINSAL, Mindfulness UC y la Universidad de Chile.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_rounded, size: 18),
                            label: const Text('Guardar rutina semanal'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...mindfulnessSessions.map(
                (session) => _SessionCard(session: session),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final MindfulnessSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2E9FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(session.duration),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(session.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.spa_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(session.focus, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.verified_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${session.source}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () {
                  // TODO: integrar reproducción de audio/video.
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Iniciar sesión'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: abrir fuente en navegador dentro de la app.
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Visitar recurso'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
