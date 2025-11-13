import 'package:mi_refugio_app/features/chatbot/data/models/chat_message_model.dart';

class ChatSessionState {
  const ChatSessionState({
    required this.messages,
    required this.quickPrompts,
    required this.isLoading,
    required this.calmScore,
    required this.focus,
    this.practice,
    this.errorMessage,
  });

  factory ChatSessionState.initial() {
    final greeting = ChatMessageModel(
      id: 'assistant-${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.assistant,
      content:
          'Hola, soy Refu. Puedo guiarte con respiraciones, grounding o conectarte con recursos profesionales. ¿Qué necesitas hoy?',
      timestamp: DateTime.now(),
      suggestions: const [
        'Necesito calmar ansiedad',
        'Quiero un ejercicio de gratitud',
        '¿Puedes recordarme beber agua?',
      ],
    );
    return ChatSessionState(
      messages: [greeting],
      quickPrompts: greeting.suggestions,
      isLoading: false,
      calmScore: 0.6,
      focus: 'Bienvenida',
      practice: null,
      errorMessage: null,
    );
  }

  final List<ChatMessageModel> messages;
  final List<String> quickPrompts;
  final bool isLoading;
  final double calmScore;
  final String focus;
  final String? practice;
  final String? errorMessage;

  ChatSessionState copyWith({
    List<ChatMessageModel>? messages,
    List<String>? quickPrompts,
    bool? isLoading,
    double? calmScore,
    String? focus,
    String? practice,
    String? errorMessage,
  }) {
    return ChatSessionState(
      messages: messages ?? this.messages,
      quickPrompts: quickPrompts ?? this.quickPrompts,
      isLoading: isLoading ?? this.isLoading,
      calmScore: calmScore ?? this.calmScore,
      focus: focus ?? this.focus,
      practice: practice ?? this.practice,
      errorMessage: errorMessage,
    );
  }
}
