import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant, system }

class ChatMessageModel extends Equatable {
  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.suggestions = const [],
  });

  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final List<String> suggestions;

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;

  ChatMessageModel copyWith({
    String? id,
    ChatRole? role,
    String? content,
    DateTime? timestamp,
    List<String>? suggestions,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'suggestions': suggestions,
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      role: ChatRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => ChatRole.assistant,
      ),
      content: json['content'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.cast<String>()
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [id, role, content, timestamp, suggestions];
}

class ChatReplyPayload {
  const ChatReplyPayload({
    required this.response,
    required this.followUps,
    required this.calmScore,
    required this.focus,
    this.practice,
  });

  final String response;
  final List<String> followUps;
  final double calmScore;
  final String focus;
  final String? practice;

  factory ChatReplyPayload.fromJson(Map<String, dynamic> json) {
    return ChatReplyPayload(
      response: json['response'] as String? ?? '',
      followUps: (json['followUps'] as List<dynamic>?)
              ?.cast<String>()
              .toList() ??
          const [],
      calmScore: (json['calmScore'] as num?)?.toDouble() ?? 0.5,
      focus: json['focus'] as String? ?? 'Respiración consciente',
      practice: json['practice'] as String?,
    );
  }
}
