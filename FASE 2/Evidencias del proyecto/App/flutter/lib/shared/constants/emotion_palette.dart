import 'package:flutter/material.dart';

class EmotionPaletteEntry {
  const EmotionPaletteEntry({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
}

class EmotionPalette {
  EmotionPalette._();

  static final cards = <EmotionPaletteEntry>[
    EmotionPaletteEntry(
      title: 'Calma',
      subtitle: 'Respira y baja el ritmo',
      emoji: '🌊',
      gradient: const [Color(0xFF1F8FF8), Color(0xFF7AD7FF)],
    ),
    EmotionPaletteEntry(
      title: 'Esperanza',
      subtitle: 'Recuerda que estás avanzando',
      emoji: '🌱',
      gradient: const [Color(0xFFFFA8A8), Color(0xFFFFE9C0)],
    ),
    EmotionPaletteEntry(
      title: 'Energía',
      subtitle: 'Activa tu cuerpo con mini retos',
      emoji: '⚡️',
      gradient: const [Color(0xFF8C4BFF), Color(0xFFFF93D0)],
    ),
    EmotionPaletteEntry(
      title: 'Conexión',
      subtitle: 'Permite que otros te acompañen',
      emoji: '🤝',
      gradient: const [Color(0xFF25C4A8), Color(0xFF7EF3CD)],
    ),
  ];
}
