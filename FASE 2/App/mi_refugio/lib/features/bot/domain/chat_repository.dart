import 'chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> fetchHistory({required int page, required int pageSize});
  Future<ChatMessage> sendMessage({required String text});
}
