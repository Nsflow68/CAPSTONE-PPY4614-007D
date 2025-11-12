import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/shared/models/mindfulness_session.dart';
import 'package:mi_refugio_app/shared/models/mindfulness_summary.dart';

final mindfulnessSessionsProvider = FutureProvider<List<MindfulnessSession>>((
  ref,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 300));
  return const [
    MindfulnessSession(
      id: 'breath',
      title: 'Respiración profunda',
      durationMinutes: 5,
      focus: 'Ansiedad',
      description:
          'Calma el sistema nervioso con una secuencia breve de respiraciones guiadas.',
      source: 'Colegio de Psicólogos de Chile',
      mediaUrl: 'https://ejemplo.cl/respiracion',
      resourceUrl: 'https://ejemplo.cl/respiracion/guia',
    ),
    MindfulnessSession(
      id: 'body-scan',
      title: 'Body Scan suave',
      durationMinutes: 8,
      focus: 'Estrés',
      description:
          'Recorre tu cuerpo con atención plena para liberar tensión acumulada.',
      source: 'Mindful.org',
      mediaUrl: 'https://ejemplo.cl/body-scan',
      resourceUrl: 'https://ejemplo.cl/body-scan/guia',
    ),
  ];
});

final mindfulnessSummaryProvider = FutureProvider<MindfulnessSummary>((
  ref,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 200));
  return MindfulnessSummary(
    completedSessions: 12,
    streakDays: 4,
    totalMinutes: 78,
    byType: const {'Ansiedad': 32, 'Estrés': 28, 'Autocompasión': 18},
  );
});
