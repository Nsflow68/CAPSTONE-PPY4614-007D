import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/features/diary/application/diary_state.dart';
import 'package:mi_refugio_app/features/diary/data/models/diary_entry_model.dart';
import 'package:mi_refugio_app/shared/data/mock_diary_entries.dart';

final diaryProvider = StateNotifierProvider<DiaryNotifier, DiaryState>((ref) {
  return DiaryNotifier()..loadEntries();
});

class DiaryNotifier extends StateNotifier<DiaryState> {
  DiaryNotifier() : super(const DiaryInitial()) {
    _entries = mockDiaryEntries.map(DiaryEntryModel.fromEntity).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  late final List<DiaryEntryModel> _entries;
  DateTime? _lastFrom;
  DateTime? _lastTo;

  static const _loadDelay = Duration(milliseconds: 350);
  static const _mutationDelay = Duration(milliseconds: 220);

  Future<void> loadEntries({DateTime? from, DateTime? to}) async {
    _lastFrom = from;
    _lastTo = to;
    state = const DiaryLoading();
    try {
      await Future<void>.delayed(_loadDelay);
      final items = _filteredEntries(from, to);
      state = DiaryLoaded(items);
    } catch (error) {
      state = DiaryError('No pudimos cargar tus registros: $error');
    }
  }

  Future<void> createEntry(DiaryEntryCreateRequest request) async {
    await Future<void>.delayed(_mutationDelay);
    final normalizedDate = DateUtils.dateOnly(request.date);
    final now = DateTime.now();
    final normalizedScore = request.score.clamp(1, 10).toInt();
    final entry = DiaryEntryModel(
      id: now.microsecondsSinceEpoch.toString(),
      title: request.title,
      content: request.content,
      mood: request.mood,
      moodText:
          request.moodText ?? _describeMood(request.mood, normalizedScore),
      score: normalizedScore,
      date: normalizedDate,
      createdAt: now,
      emotions: List<String>.unmodifiable(request.emotions),
      tags: List<String>.unmodifiable(request.tags),
    );

    _entries.insert(0, entry);
    state = DiaryLoaded(_filteredEntries(_lastFrom, _lastTo));
  }

  List<DiaryEntryModel> _filteredEntries(DateTime? from, DateTime? to) {
    Iterable<DiaryEntryModel> current = _entries;

    if (from != null) {
      final start = DateUtils.dateOnly(from);
      current = current.where((entry) => !entry.date.isBefore(start));
    }

    if (to != null) {
      final end = DateUtils.dateOnly(to);
      current = current.where((entry) => !entry.date.isAfter(end));
    }

    final sorted = current.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  String _describeMood(String mood, int score) {
    final normalized = mood.trim().isEmpty
        ? 'tu estado actual'
        : mood.toLowerCase();
    if (score >= 8) {
      return 'Viviste $normalized con mucha energ\u00eda positiva.';
    } else if (score >= 5) {
      return 'Percibiste $normalized de forma equilibrada y consciente.';
    } else {
      return 'Sentiste $normalized con baja energ\u00eda, recuerda darte espacio para cuidarte.';
    }
  }
}
