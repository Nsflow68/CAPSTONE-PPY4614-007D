import 'package:mi_refugio_app/features/chatbot/data/models/chat_message_model.dart';
import 'package:mi_refugio_app/features/chatbot/data/models/chatbot_failure.dart';

/// Estados del chatbot usando el patrón consistente con Auth y Diary.
sealed class ChatbotState {
  const ChatbotState();

  T map<T>({
    required T Function(ChatbotInitial) initial,
    required T Function(ChatbotLoading) loading,
    required T Function(ChatbotLoaded) loaded,
    required T Function(ChatbotError) error,
  }) {
    final state = this;
    if (state is ChatbotInitial) return initial(state);
    if (state is ChatbotLoading) return loading(state);
    if (state is ChatbotLoaded) return loaded(state);
    if (state is ChatbotError) return error(state);
    throw Exception('Unknown ChatbotState: $state');
  }

  T maybeMap<T>({
    T Function(ChatbotInitial)? initial,
    T Function(ChatbotLoading)? loading,
    T Function(ChatbotLoaded)? loaded,
    T Function(ChatbotError)? error,
    required T Function() orElse,
  }) {
    final state = this;
    if (state is ChatbotInitial && initial != null) return initial(state);
    if (state is ChatbotLoading && loading != null) return loading(state);
    if (state is ChatbotLoaded && loaded != null) return loaded(state);
    if (state is ChatbotError && error != null) return error(state);
    return orElse();
  }
}

/// Estado inicial del chatbot con mensaje de bienvenida.
class ChatbotInitial extends ChatbotState {
  const ChatbotInitial() : super();

  /// Mensaje de bienvenida predeterminado.
  static ChatMessageModel get welcomeMessage {
    return ChatMessageModel(
      id: 'assistant-welcome',
      role: ChatRole.assistant,
      content:
          'Hola, soy Refu. Puedo guiarte con respiraciones, grounding o conectarte con recursos profesionales. ¿Qué necesitas hoy?',
      timestamp: DateTime.now(),
      suggestions: const [
        'Necesito calmar ansiedad',
        'Quiero un ejercicio de gratitud',
        'Registrar emoción de hoy',
      ],
    );
  }
}

/// Estado de carga mientras se procesa un mensaje.
class ChatbotLoading extends ChatbotState {
  const ChatbotLoading(this.messages) : super();

  final List<ChatMessageModel> messages;
}

/// Estado con mensajes cargados correctamente.
class ChatbotLoaded extends ChatbotState {
  const ChatbotLoaded(this.messages) : super();

  final List<ChatMessageModel> messages;

  ChatbotLoaded copyWith({List<ChatMessageModel>? messages}) {
    return ChatbotLoaded(messages ?? this.messages);
  }
}

/// Estado de error con detalles del fallo.
class ChatbotError extends ChatbotState {
  const ChatbotError(this.failure, this.messages) : super();

  final ChatbotFailure failure;
  final List<ChatMessageModel> messages;
}
