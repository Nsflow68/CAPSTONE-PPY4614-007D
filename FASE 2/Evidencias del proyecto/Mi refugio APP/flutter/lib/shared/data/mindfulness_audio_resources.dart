class MindfulnessAudioResource {
  const MindfulnessAudioResource({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.credits,
    required this.assetPath,
    required this.sourceLabel,
    required this.sourceUrl,
  });

  final String title;
  final String subtitle;
  final String duration;
  final String credits;
  final String assetPath;
  final String sourceLabel;
  final String sourceUrl;
}

const mindfulnessAudioResources = <MindfulnessAudioResource>[
  MindfulnessAudioResource(
    title: 'Atención a la respiración',
    subtitle: 'Secuencia corta para volver al presente.',
    duration: '10 min',
    credits: 'Guion y voz: Paula Ariza',
    assetPath: 'audio/mindfulness_atencion_10min.mp3',
    sourceLabel: 'Ministerio de Salud de Chile',
    sourceUrl: 'https://www.minsal.cl/mi-salud-mental/guias/respiracion',
  ),
  MindfulnessAudioResource(
    title: 'Exploración corporal',
    subtitle: 'Recorrido guiado para conectar con sensaciones físicas.',
    duration: '16 min',
    credits: 'Guion y voz: Paula Ariza',
    assetPath: 'audio/mindfulness_exploracion_16min.mp3',
    sourceLabel: 'Hospital Digital',
    sourceUrl: 'https://www.hospitaldigital.gob.cl/mindfulness',
  ),
  MindfulnessAudioResource(
    title: 'Meditación compasiva',
    subtitle: 'Visualización para cultivar amabilidad y cuidado.',
    duration: '26 min',
    credits: 'Guion y voz: Paula Ariza',
    assetPath: 'audio/mindfulness_compasion_26min.mp3',
    sourceLabel: 'Mindfulness UC',
    sourceUrl: 'https://mindfulness.uc.cl/recursos',
  ),
];
