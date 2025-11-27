import 'package:equatable/equatable.dart';
import 'package:mi_refugio_app/shared/models/diary_entry.dart';

class DiaryEntryModel extends Equatable {
  const DiaryEntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.moodText,
    required this.score,
    required this.date,
    required this.createdAt,
    this.emotions = const [],
    this.tags = const [],
  });

  final String id;
  final String title;
  final String content;
  final String mood;
  final String moodText;
  final int score;
  final DateTime date;
  final DateTime createdAt;
  final List<String> emotions;
  final List<String> tags;

  factory DiaryEntryModel.fromEntity(DiaryEntry entry) {
    final normalDate = DateTime(
      entry.date.year,
      entry.date.month,
      entry.date.day,
    );
    return DiaryEntryModel(
      id: entry.id,
      title: entry.title,
      content: entry.content,
      mood: entry.mood,
      moodText: entry.moodText,
      score: entry.score,
      date: normalDate,
      createdAt: entry.createdAt,
      emotions: List<String>.unmodifiable(entry.emotions),
      tags: List<String>.unmodifiable(entry.tags),
    );
  }

  DiaryEntryModel copyWith({
    String? id,
    String? title,
    String? content,
    String? mood,
    String? moodText,
    int? score,
    DateTime? date,
    DateTime? createdAt,
    List<String>? emotions,
    List<String>? tags,
  }) {
    return DiaryEntryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      moodText: moodText ?? this.moodText,
      score: score ?? this.score,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      emotions: emotions ?? this.emotions,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    mood,
    moodText,
    score,
    date,
    createdAt,
    emotions,
    tags,
  ];
}

class DiaryEntryCreateRequest {
  DiaryEntryCreateRequest({
    required this.date,
    required this.title,
    required this.content,
    required this.mood,
    required this.emotions,
    required this.tags,
    required this.score,
    this.moodText,
    this.attachments = const [],
  });

  final DateTime date;
  final String title;
  final String content;
  final String mood;
  final List<String> emotions;
  final List<String> tags;
  final int score;
  final String? moodText;
  final List<String> attachments;

  DiaryEntryCreateRequest copyWith({
    DateTime? date,
    String? title,
    String? content,
    String? mood,
    List<String>? emotions,
    List<String>? tags,
    int? score,
    String? moodText,
    List<String>? attachments,
  }) {
    return DiaryEntryCreateRequest(
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      emotions: emotions ?? this.emotions,
      tags: tags ?? this.tags,
      score: score ?? this.score,
      moodText: moodText ?? this.moodText,
      attachments: attachments ?? this.attachments,
    );
  }

  DiaryEntry toEntity() {
    return DiaryEntry(
      id: '',
      title: title,
      content: content,
      mood: mood,
      moodText: moodText ?? '',
      score: score,
      date: date,
      createdAt: DateTime.now(),
      emotions: emotions,
      tags: tags,
    );
  }
}
