import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_repository.dart';
import 'bot_providers.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  const ChatState({required this.messages, required this.isSending});
  ChatState copyWith({List<ChatMessage>? messages, bool? isSending}) =>
      ChatState(messages: messages ?? this.messages, isSending: isSending ?? this.isSending);
  factory ChatState.initial() => const ChatState(messages: [], isSending: false);
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  final repo = ref.read(chatRepositoryProvider);
  return ChatController(repo)..loadFirstPage();
});

class ChatController extends StateNotifier<ChatState> {
  final ChatRepository _repo;
  ChatController(this._repo) : super(ChatState.initial());

  Future<void> loadFirstPage() async {
    final items = await _repo.fetchHistory(page: 1, pageSize: 20);
    state = state.copyWith(messages: items);
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    state = state.copyWith(isSending: true);
    final user = await _repo.sendMessage(text: text);
    final updated = [...state.messages, user];
    // Respuesta simulada rápida si aún no hay backend que responda
    final assistant = ChatMessage(
      id: 'assistant_local',
      role: ChatRole.assistant,
      content: 'Gracias por tu mensaje: "$text". Estoy aquí para ayudarte 💙',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...updated, assistant], isSending: false);
  }
}
