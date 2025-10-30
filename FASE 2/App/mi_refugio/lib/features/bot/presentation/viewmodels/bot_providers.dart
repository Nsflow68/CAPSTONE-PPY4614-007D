import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mi_refugio/core/config/app_env.dart';
import '../../data/chat_repository_impl.dart';
import '../../domain/chat_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: AppEnv.apiBase, connectTimeout: const Duration(seconds: 10)));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dio = ref.read(dioProvider);
  return ChatRepositoryImpl(dio);
});
