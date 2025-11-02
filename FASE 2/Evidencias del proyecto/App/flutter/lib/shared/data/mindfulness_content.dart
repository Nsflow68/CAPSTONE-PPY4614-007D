class MindfulnessSession {
  const MindfulnessSession({
    required this.title,
    required this.description,
    required this.duration,
    required this.focus,
    required this.source,
    required this.url,
  });

  final String title;
  final String description;
  final String duration;
  final String focus;
  final String source;
  final String url;
}

const mindfulnessSessions = <MindfulnessSession>[
  MindfulnessSession(
    title: 'Pausa consciente guiada',
    description:
        'Sesión breve basada en el programa de mindfulness del Ministerio de Salud de Chile.',
    duration: '10 min',
    focus: 'Respiración y gratitud matinal',
    source: 'MINSAL · Estrategia Saludablemente',
    url: 'https://www.minsal.cl/saludablemente/',
  ),
  MindfulnessSession(
    title: 'Respiración 4-7-8',
    description:
        'Técnica de regulación emocional promovida por la Clínica Alemana para reducir el estrés.',
    duration: '6 min',
    focus: 'Gestión de ansiedad',
    source: 'Clínica Alemana · Bienestar Digital',
    url: 'https://www.clinicaalemana.cl/bienestar',
  ),
  MindfulnessSession(
    title: 'Escaneo corporal suave',
    description:
        'Ejercicio inspirado en MindfulnessUC para reconectar con el cuerpo y liberar tensión.',
    duration: '12 min',
    focus: 'Relajación corporal',
    source: 'Centro Mindfulness UC',
    url: 'https://mindfulness.uc.cl/recursos/',
  ),
  MindfulnessSession(
    title: 'Meditación caminando',
    description:
        'Guía de Respiracción (Universidad de Chile) para integrar mindfulness en movimiento.',
    duration: '8 min',
    focus: 'Atención plena en movimiento',
    source: 'Programa Respira UChile',
    url: 'https://www.saludmental.uchile.cl/respira',
  ),
];
