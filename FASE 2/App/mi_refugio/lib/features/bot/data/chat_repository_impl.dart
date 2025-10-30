import 'package:dio/dio.dart';
import 'package:mi_refugio/core/config/app_env.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Dio _dio;
  ChatRepositoryImpl(this._dio);

  @override
  Future<List<ChatMessage>> fetchHistory({required int page, required int pageSize}) async {
    try {
      final res = await _dio.get('${AppEnv.chatHttp}/history', queryParameters: {'page': page, 'limit': pageSize});
      final items = (res.data['items'] as List? ?? []);
      return items.map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      // fallback vacío si aún no hay backend
      return <ChatMessage>[];
    }
  }

  @override
  Future<ChatMessage> sendMessage({required String text}) async {
    try {
      final res = await _dio.post(AppEnv.chatHttp, data: {'text': text});
      return ChatMessage.fromJson(Map<String, dynamic>.from(res.data));
    } catch (_) {
      return ChatMessage(
        id: 'local',
        role: ChatRole.user,
        content: text,
        createdAt: DateTime.now(),
      );
    }
  }
}
