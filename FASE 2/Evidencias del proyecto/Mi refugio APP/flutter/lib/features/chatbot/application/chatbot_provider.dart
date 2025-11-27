import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/features/chatbot/application/chatbot_state.dart';
import 'package:mi_refugio_app/features/chatbot/data/chatbot_repository.dart';
import 'package:mi_refugio_app/features/chatbot/data/models/chat_message_model.dart';

final chatbotProvider =
    StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  return ChatbotNotifier(ChatbotRepository());
});

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  ChatbotNotifier(this._repository) : super(const ChatbotInitial()) {
    _initializeChat();
  }

  final ChatbotRepository _repository;
  final List<ChatMessageModel> _messages = [];

  /// Inicializa el chat cargando el historial o mostrando el mensaje de bienvenida.
  void _initializeChat() {
    final welcome = ChatbotInitial.welcomeMessage;
    _messages.add(welcome);
    state = ChatbotLoaded([welcome]);
  }

  /// Carga el historial de mensajes desde el backend.
  Future<void> loadHistory() async {
    state = ChatbotLoading(_messages);

    final result = await _repository.loadHistory();
    result.when(
      success: (messages) {
        _messages.clear();
        _messages.addAll(messages);

        // Si no hay mensajes, agregar el de bienvenida
        if (_messages.isEmpty) {
          final welcome = ChatbotInitial.welcomeMessage;
          _messages.add(welcome);
        }

        state = ChatbotLoaded(List.from(_messages));
      },
      failure: (failure) {
        state = ChatbotError(failure, List.from(_messages));
      },
    );
  }

  /// Envía un mensaje al chatbot y espera la respuesta.
  Future<void> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    // Agregar mensaje del usuario
    final userMessage = ChatMessageModel(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      content: trimmed,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    state = ChatbotLoading(List.from(_messages));

    // Enviar al backend
    final result = await _repository.sendMessage(trimmed);
    result.when(
      success: (botMessage) {
        _messages.add(botMessage);
        state = ChatbotLoaded(List.from(_messages));
      },
      failure: (failure) {
        state = ChatbotError(failure, List.from(_messages));
      },
    );
  }

  /// Reinicia la sesión del chat.
  void resetSession() {
    _messages.clear();
    state = const ChatbotInitial();
    _initializeChat();
  }
}
