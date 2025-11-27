import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/features/diary/application/diary_state.dart';
import 'package:mi_refugio_app/features/diary/data/diary_repository.dart';
import 'package:mi_refugio_app/features/diary/data/models/diary_entry_model.dart';

final diaryProvider = StateNotifierProvider<DiaryNotifier, DiaryState>((ref) {
  return DiaryNotifier(DiaryRepository())..loadEntries();
});

class DiaryNotifier extends StateNotifier<DiaryState> {
  DiaryNotifier(this._repository) : super(const DiaryInitial());

  final DiaryRepository _repository;
  DateTime? _lastFrom;
  DateTime? _lastTo;

  Future<void> loadEntries({DateTime? from, DateTime? to}) async {
    _lastFrom = from;
    _lastTo = to;
    state = const DiaryLoading();

    final result = await _repository.getEntries();
    result.when(
      success: (items) {
        final filtered = _filterEntries(items, from, to);
        state = filtered.isEmpty ? const DiaryEmpty() : DiaryLoaded(filtered);
      },
      failure: (failure) => state = DiaryError(failure),
    );
  }

  Future<void> createEntry(DiaryEntryCreateRequest request) async {
    state = const DiaryLoading();

    final normalizedDate = DateUtils.dateOnly(request.date);
    final now = DateTime.now();
    final normalizedScore = request.score.clamp(1, 10).toInt();

    final entry = DiaryEntryModel(
      id: '', // El backend asignará el ID
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

    final result = await _repository.createEntry(entry);
    result.when(
      success: (_) {
        // Recarga las entradas para mostrar la nueva entrada
        loadEntries(from: _lastFrom, to: _lastTo);
      },
      failure: (failure) => state = DiaryError(failure),
    );
  }

  List<DiaryEntryModel> _filterEntries(
    List<DiaryEntryModel> entries,
    DateTime? from,
    DateTime? to,
  ) {
    Iterable<DiaryEntryModel> current = entries;

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
    final normalized =
        mood.trim().isEmpty ? 'tu estado actual' : mood.toLowerCase();
    if (score >= 8) {
      return 'Viviste $normalized con mucha energía positiva.';
    } else if (score >= 5) {
      return 'Percibiste $normalized de forma equilibrada y consciente.';
    } else {
      return 'Sentiste $normalized con baja energía, recuerda darte espacio para cuidarte.';
    }
  }
}
