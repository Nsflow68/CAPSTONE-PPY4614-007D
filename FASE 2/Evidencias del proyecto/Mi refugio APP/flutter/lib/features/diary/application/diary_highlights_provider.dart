import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mi_refugio_app/features/diary/application/diary_provider.dart';
import 'package:mi_refugio_app/features/diary/application/diary_state.dart';
import 'package:mi_refugio_app/features/diary/data/models/diary_entry_model.dart';

final diaryHighlightsProvider = Provider<List<DiaryHighlight>>((ref) {
  final state = ref.watch(diaryProvider);
  if (state is! DiaryLoaded) {
    return const [];
  }
  final entries = List<DiaryEntryModel>.from(state.entries);
  if (entries.isEmpty) {
    return const [];
  }

  entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final window = entries.take(5).toList();
  final highlights = <DiaryHighlight>[];

  for (var i = 0; i < window.length; i++) {
    final entry = window[i];
    final previous = i + 1 < entries.length ? entries[i + 1] : null;
    final delta = previous != null ? entry.score - previous.score : 0;
    highlights.add(
      DiaryHighlight(
        id: entry.id,
        mood: entry.mood,
        description: entry.moodText.isNotEmpty ? entry.moodText : entry.content,
        score: entry.score,
        date: entry.date,
        emotions: entry.emotions,
        scoreDelta: delta,
      ),
    );
  }

  return List<DiaryHighlight>.unmodifiable(highlights);
});

class DiaryHighlight {
  const DiaryHighlight({
    required this.id,
    required this.mood,
    required this.description,
    required this.score,
    required this.date,
    required this.emotions,
    required this.scoreDelta,
  });

  final String id;
  final String mood;
  final String description;
  final int score;
  final DateTime date;
  final List<String> emotions;
  final int scoreDelta;
}
