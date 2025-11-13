import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/features/chatbot/application/chatbot_state.dart';
import 'package:mi_refugio_app/features/chatbot/data/models/chat_message_model.dart';
import 'package:mi_refugio_app/features/chatbot/services/refu_bot_service.dart';

final refuBotServiceProvider = Provider<RefuBotService>((ref) {
  return RefuBotService();
});

final chatSessionProvider =
    StateNotifierProvider<ChatSessionNotifier, ChatSessionState>((ref) {
  return ChatSessionNotifier(ref.read(refuBotServiceProvider));
});

class ChatSessionNotifier extends StateNotifier<ChatSessionState> {
  ChatSessionNotifier(this._service) : super(ChatSessionState.initial());

  final RefuBotService _service;

  Future<void> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMessage = ChatMessageModel(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      role: ChatRole.user,
      content: trimmed,
      timestamp: DateTime.now(),
    );

    final history = [...state.messages, userMessage];
    state = state.copyWith(
      messages: history,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final reply = await _service.sendMessage(
        prompt: trimmed,
        history: history,
      );

      final botMessage = ChatMessageModel(
        id: 'assistant-${DateTime.now().microsecondsSinceEpoch}',
        role: ChatRole.assistant,
        content: reply.response,
        timestamp: DateTime.now(),
        suggestions: reply.followUps,
      );

      state = state.copyWith(
        messages: [...history, botMessage],
        isLoading: false,
        quickPrompts: reply.followUps.isNotEmpty ? reply.followUps : state.quickPrompts,
        calmScore: reply.calmScore,
        focus: reply.focus,
        practice: reply.practice,
        errorMessage: null,
      );
    } catch (error, stacktrace) {
      debugPrint('RefuBot error: $error\n$stacktrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No pudimos contactar a Refu. Inténtalo de nuevo.',
      );
    }
  }

  void usePrompt(String prompt) {
    sendMessage(prompt);
  }

  void resetSession() {
    state = ChatSessionState.initial();
  }
}
