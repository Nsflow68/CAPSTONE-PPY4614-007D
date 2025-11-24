import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mi_refugio_app/core/services/api_service.dart';
import 'package:mi_refugio_app/core/types/result.dart';
import 'package:mi_refugio_app/features/diary/data/models/diary_entry_model.dart';
import 'package:mi_refugio_app/features/diary/data/models/diary_failure.dart';

/// Repository que conecta con el backend real para operaciones del diario.
///
/// Endpoints utilizados:
/// - GET /diary - Obtiene todos los registros del usuario
/// - POST /diary - Crea un nuevo registro
class DiaryRepository {
  DiaryRepository({ApiService? apiService})
      : _api = apiService ?? ApiService.instance;

  final ApiService _api;

  /// Obtiene todos los registros del diario del usuario actual.
  ///
  /// Mapea la respuesta del backend al modelo de Flutter.
  /// Backend devuelve: { id, title, body, mood, createdAt, tags, userId }
  /// Flutter espera: DiaryEntryModel con campos adicionales.
  Future<Result<List<DiaryEntryModel>, DiaryFailure>> getEntries() async {
    try {
      final response = await _api.getRaw('diary');

      if (response.statusCode == 200) {
        final List<dynamic> data = await _api.getJson('diary');
        final entries = data
            .map((json) => _mapBackendToModel(json as Map<String, dynamic>))
            .toList();
        return Success(entries);
      }

      return Failure(_mapStatusToFailure(response.statusCode, response.body));
    } on TimeoutException catch (_) {
      return const Failure(
        DiaryFailure(
          DiaryFailureType.network,
          message: 'La solicitud tardó demasiado tiempo',
        ),
      );
    } on SocketException catch (_) {
      return const Failure(
        DiaryFailure(
          DiaryFailureType.network,
          message: 'No se pudo conectar con el servidor',
        ),
      );
    } on http.ClientException catch (_) {
      return const Failure(
        DiaryFailure(
          DiaryFailureType.network,
          message: 'Error de conexión con el servidor',
        ),
      );
    } catch (e) {
      return Failure(
        DiaryFailure(
          DiaryFailureType.unknown,
          message: 'Error inesperado: ${e.toString()}',
        ),
      );
    }
  }

  /// Crea un nuevo registro en el diario.
  ///
  /// Mapea el modelo de Flutter a la estructura esperada por el backend.
  /// Backend espera: { title, body, mood, createdAt?, tags? }
  Future<Result<DiaryEntryModel, DiaryFailure>> createEntry(
    DiaryEntryModel entry,
  ) async {
    try {
      final payload = _mapModelToBackend(entry);
      final response = await _api.postRaw('diary', body: payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = await _api.postJson('diary', body: payload);
        final created = _mapBackendToModel(data);
        return Success(created);
      }

      return Failure(_mapStatusToFailure(response.statusCode, response.body));
    } on TimeoutException catch (_) {
      return const Failure(
        DiaryFailure(
          DiaryFailureType.network,
          message: 'La solicitud tardó demasiado tiempo',
        ),
      );
    } on SocketException catch (_) {
      return const Failure(
        DiaryFailure(
          DiaryFailureType.network,
          message: 'No se pudo conectar con el servidor',
        ),
      );
    } on http.ClientException catch (_) {
      return const Failure(
        DiaryFailure(
          DiaryFailureType.network,
          message: 'Error de conexión con el servidor',
        ),
      );
    } catch (e) {
      return Failure(
        DiaryFailure(
          DiaryFailureType.unknown,
          message: 'Error inesperado: ${e.toString()}',
        ),
      );
    }
  }

  /// Mapea la respuesta del backend al modelo de Flutter.
  ///
  /// Backend: { id, title, body, mood, createdAt, tags, userId }
  /// Flutter: DiaryEntryModel con campos adicionales
  DiaryEntryModel _mapBackendToModel(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now();

    // El backend no tiene score, moodText, emotions ni date separado.
    // Generamos valores por defecto razonables.
    final mood = (json['mood'] as String? ?? '').trim();
    final score = _inferScoreFromMood(mood);
    final moodText = _generateMoodText(mood, score);

    return DiaryEntryModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      content: json['body'] as String? ?? '', // backend usa "body"
      mood: mood,
      moodText: moodText,
      score: score,
      date: DateTime(createdAt.year, createdAt.month, createdAt.day),
      createdAt: createdAt,
      emotions: const [], // backend no tiene emotions, usamos lista vacía
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tag) => tag.toString())
              .toList() ??
          const [],
    );
  }

  /// Mapea el modelo de Flutter a la estructura del backend.
  ///
  /// Backend espera: { title, body, mood, createdAt?, tags? }
  Map<String, dynamic> _mapModelToBackend(DiaryEntryModel entry) {
    return {
      'title': entry.title,
      'body': entry.content, // Flutter usa "content", backend usa "body"
      'mood': entry.mood,
      'createdAt': entry.createdAt.toIso8601String(),
      'tags': entry.tags,
    };
  }

  /// Mapea códigos de estado HTTP a DiaryFailure apropiados.
  DiaryFailure _mapStatusToFailure(int statusCode, String body) {
    switch (statusCode) {
      case 400:
        return DiaryFailure(
          DiaryFailureType.invalidData,
          message: _extractErrorMessage(body),
        );
      case 401:
      case 403:
        return const DiaryFailure(
          DiaryFailureType.unauthorized,
          message: 'No autorizado. Inicia sesión nuevamente.',
        );
      case 404:
        return const DiaryFailure(
          DiaryFailureType.notFound,
          message: 'Recurso no encontrado',
        );
      case >= 500 && < 600:
        return DiaryFailure(
          DiaryFailureType.server,
          message: _extractErrorMessage(body),
        );
      default:
        return DiaryFailure(
          DiaryFailureType.unknown,
          message: 'Error desconocido: HTTP $statusCode',
        );
    }
  }

  /// Intenta extraer un mensaje de error legible del cuerpo de la respuesta.
  String? _extractErrorMessage(String body) {
    try {
      if (body.isEmpty) return null;
      // Intenta parsear como JSON y extraer mensaje
      if (body.contains('message') || body.contains('error')) {
        return body.length > 200 ? body.substring(0, 200) : body;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Infiere un score (1-10) basado en el mood.
  /// Esta es una heurística simple ya que el backend no devuelve score.
  int _inferScoreFromMood(String mood) {
    final normalized = mood.toLowerCase().trim();

    // Estados muy positivos
    if (normalized.contains('alegre') ||
        normalized.contains('feliz') ||
        normalized.contains('excelente') ||
        normalized.contains('genial')) {
      return 9;
    }

    // Estados positivos
    if (normalized.contains('bien') ||
        normalized.contains('tranquilo') ||
        normalized.contains('contento')) {
      return 7;
    }

    // Estados negativos
    if (normalized.contains('triste') ||
        normalized.contains('ansioso') ||
        normalized.contains('preocupado')) {
      return 4;
    }

    // Estados muy negativos
    if (normalized.contains('mal') ||
        normalized.contains('deprimido') ||
        normalized.contains('terrible')) {
      return 2;
    }

    // Neutral/desconocido
    return 5;
  }

  /// Genera un texto descriptivo del mood basado en el mood y score.
  String _generateMoodText(String mood, int score) {
    final normalized = mood.trim().isEmpty ? 'tu estado actual' : mood.toLowerCase();

    if (score >= 8) {
      return 'Viviste $normalized con mucha energía positiva.';
    } else if (score >= 5) {
      return 'Percibiste $normalized de forma equilibrada y consciente.';
    } else {
      return 'Sentiste $normalized con baja energía, recuerda darte espacio para cuidarte.';
    }
  }
}
