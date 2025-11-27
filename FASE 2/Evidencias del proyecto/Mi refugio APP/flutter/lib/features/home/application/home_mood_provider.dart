import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/constants/emotion_palette.dart';
import '../../diary/application/diary_provider.dart';
import '../../diary/application/diary_state.dart';
import '../../diary/data/models/diary_entry_model.dart';

final homeMoodProvider = Provider<HomeMoodHighlight>((ref) {
  final state = ref.watch(diaryProvider);
  if (state is DiaryLoaded && state.entries.isNotEmpty) {
    return HomeMoodHighlight.fromEntry(state.entries.first);
  }
  return const HomeMoodHighlight.fallback();
});

class HomeMoodHighlight {
  const HomeMoodHighlight({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.scoreLabel,
    required this.dateLabel,
    required this.emoji,
    required this.mood,
    required this.emotions,
    required this.hasEntry,
  });

  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String scoreLabel;
  final String dateLabel;
  final String emoji;
  final String mood;
  final List<String> emotions;
  final bool hasEntry;

  factory HomeMoodHighlight.fromEntry(DiaryEntryModel entry) {
    final palette = _paletteFor(entry.mood, entry.emotions);
    final formatter = DateFormat('d MMMM', 'es');
    final dateLabel = formatter.format(entry.date);
    return HomeMoodHighlight(
      title: '${palette.emoji} ${entry.mood}',
      subtitle: entry.moodText.isNotEmpty ? entry.moodText : palette.subtitle,
      gradient: palette.gradient,
      scoreLabel: '${entry.score}/10 bienestar',
      dateLabel: dateLabel,
      emoji: palette.emoji,
      mood: entry.mood,
      emotions: entry.emotions,
      hasEntry: true,
    );
  }

  const HomeMoodHighlight.fallback()
      : title = 'Mi Refugio',
        subtitle =
            'Registra tu emoción de hoy y descubre recomendaciones personalizadas.',
        gradient = const [Color(0xFF7F79F9), Color(0xFF8BE1D0)],
        scoreLabel = 'Bienestar pendiente',
        dateLabel = 'Hoy',
        emoji = '✨',
        mood = 'Explora',
        emotions = const [],
        hasEntry = false;
}

EmotionPaletteEntry _paletteFor(String mood, List<String> emotions) {
  final allHints = [
    mood,
    ...emotions,
  ].join(' ').toLowerCase();

  if (_matches(allHints, ['calm', 'seren', 'relaj'])) {
    return EmotionPalette.cards[0];
  }
  if (_matches(allHints, ['esper', 'gratitud', 'agrade'])) {
    return EmotionPalette.cards[1];
  }
  if (_matches(allHints, ['energ', 'motiva', 'aleg', 'logro'])) {
    return EmotionPalette.cards[2];
  }
  if (_matches(allHints, ['conex', 'apoyo', 'amistad', 'compasi'])) {
    return EmotionPalette.cards[3];
  }
  return EmotionPalette.cards.first;
}

bool _matches(String text, List<String> keywords) {
  for (final keyword in keywords) {
    if (text.contains(keyword)) {
      return true;
    }
  }
  return false;
}
