import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mi_refugio_app/core/services/api_service.dart';
import 'package:mi_refugio_app/core/types/result.dart';
import 'package:mi_refugio_app/features/chatbot/data/models/chat_message_model.dart';
import 'package:mi_refugio_app/features/chatbot/data/models/chatbot_failure.dart';

/// Repository que conecta con el backend real para operaciones del chatbot.
///
/// Endpoints utilizados:
/// - GET /chatbot/history - Obtiene el historial de mensajes
/// - POST /chatbot/messages - Envía un mensaje y recibe respuesta del bot
class ChatbotRepository {
  ChatbotRepository({ApiService? apiService})
      : _api = apiService ?? ApiService.instance;

  final ApiService _api;

  /// Obtiene el historial completo de mensajes del chat.
  ///
  /// Backend devuelve: { data: ChatMessage[] }
  /// Donde ChatMessage = { id, role, content, createdAt }
  Future<Result<List<ChatMessageModel>, ChatbotFailure>> loadHistory() async {
    try {
      final response = await _api.getRaw('chatbot/history');

      if (response.statusCode == 200) {
        final Map<String, dynamic> result =
            await _api.getJson('chatbot/history');
        final List<dynamic> data = result['data'] as List<dynamic>? ?? [];
        final messages = data
            .map((json) => _mapBackendToModel(json as Map<String, dynamic>))
            .toList();
        return Success(messages);
      }

      return Failure(_mapStatusToFailure(response.statusCode, response.body));
    } on TimeoutException catch (_) {
      return const Failure(
        ChatbotFailure(
          ChatbotFailureType.network,
          message: 'La solicitud tardó demasiado tiempo',
        ),
      );
    } on SocketException catch (_) {
      return const Failure(
        ChatbotFailure(
          ChatbotFailureType.network,
          message: 'No se pudo conectar con el servidor',
        ),
      );
    } on http.ClientException catch (_) {
      return const Failure(
        ChatbotFailure(
          ChatbotFailureType.network,
          message: 'Error de conexión con el servidor',
        ),
      );
    } catch (e) {
      return Failure(
        ChatbotFailure(
          ChatbotFailureType.unknown,
          message: 'Error inesperado: ${e.toString()}',
        ),
      );
    }
  }

  /// Envía un mensaje al chatbot y recibe la respuesta del asistente.
  ///
  /// Backend espera: { message: string }
  /// Backend devuelve: { data: ChatMessage }
  Future<Result<ChatMessageModel, ChatbotFailure>> sendMessage(
    String message,
  ) async {
    try {
      final payload = {'message': message};
      final response = await _api.postRaw('chatbot/messages', body: payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> result =
            await _api.postJson('chatbot/messages', body: payload);
        final Map<String, dynamic> data =
            result['data'] as Map<String, dynamic>? ?? {};
        final botMessage = _mapBackendToModel(data);
        return Success(botMessage);
      }

      return Failure(_mapStatusToFailure(response.statusCode, response.body));
    } on TimeoutException catch (_) {
      return const Failure(
        ChatbotFailure(
          ChatbotFailureType.network,
          message: 'La solicitud tardó demasiado tiempo',
        ),
      );
    } on SocketException catch (_) {
      return const Failure(
        ChatbotFailure(
          ChatbotFailureType.network,
          message: 'No se pudo conectar con el servidor',
        ),
      );
    } on http.ClientException catch (_) {
      return const Failure(
        ChatbotFailure(
          ChatbotFailureType.network,
          message: 'Error de conexión con el servidor',
        ),
      );
    } catch (e) {
      return Failure(
        ChatbotFailure(
          ChatbotFailureType.unknown,
          message: 'Error inesperado: ${e.toString()}',
        ),
      );
    }
  }

  /// Mapea la respuesta del backend al modelo de Flutter.
  ///
  /// Backend: { id, role, content, createdAt }
  /// Flutter: ChatMessageModel con campos adicionales (suggestions)
  ChatMessageModel _mapBackendToModel(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'assistant';
    final role = _parseRole(roleStr);

    final createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();

    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      role: role,
      content: json['content'] as String? ?? '',
      timestamp: createdAt,
      suggestions: const [], // Backend no provee suggestions
    );
  }

  /// Parsea el role del backend al enum de Flutter.
  ChatRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return ChatRole.user;
      case 'assistant':
        return ChatRole.assistant;
      case 'system':
        return ChatRole.system;
      default:
        return ChatRole.assistant;
    }
  }

  /// Mapea códigos de estado HTTP a ChatbotFailure apropiados.
  ChatbotFailure _mapStatusToFailure(int statusCode, String body) {
    switch (statusCode) {
      case 400:
        return ChatbotFailure(
          ChatbotFailureType.invalidData,
          message: _extractErrorMessage(body),
        );
      case 401:
      case 403:
        return const ChatbotFailure(
          ChatbotFailureType.unauthorized,
          message: 'No autorizado. Inicia sesión nuevamente.',
        );
      case 404:
        return const ChatbotFailure(
          ChatbotFailureType.notFound,
          message: 'Servicio de chat no encontrado',
        );
      case >= 500 && < 600:
        return ChatbotFailure(
          ChatbotFailureType.server,
          message: _extractErrorMessage(body),
        );
      default:
        return ChatbotFailure(
          ChatbotFailureType.unknown,
          message: 'Error desconocido: HTTP $statusCode',
        );
    }
  }

  /// Intenta extraer un mensaje de error legible del cuerpo de la respuesta.
  String? _extractErrorMessage(String body) {
    try {
      if (body.isEmpty) return null;
      if (body.contains('message') || body.contains('error')) {
        return body.length > 200 ? body.substring(0, 200) : body;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
