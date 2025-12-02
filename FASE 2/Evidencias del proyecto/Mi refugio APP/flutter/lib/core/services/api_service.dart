import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mi_refugio_app/core/config/app_config.dart';
import 'package:mi_refugio_app/core/services/storage_service.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  http.Client? _client;
  StorageService? _storage;

  Map<String, String> _defaultHeaders = const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  void initialize({http.Client? client, StorageService? storage}) {
    _client?.close();
    _client = client ?? http.Client();
    _storage = storage;
  }

  http.Client get _http => _client ??= http.Client();

  Map<String, String> get defaultHeaders => Map.unmodifiable(_defaultHeaders);

  void setDefaultHeaders(Map<String, String> headers) {
    _defaultHeaders = Map.of(headers);
  }

  Uri buildUri(String path, [Map<String, String>? queryParameters]) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    print('API SERVICE: Base URL = ${AppConfig.apiBaseUrl}');
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    print('API SERVICE: Normalized path = $normalizedPath');
    final resolved = base.resolve(normalizedPath);
    print('API SERVICE: Resolved URI = $resolved');
    return queryParameters == null
        ? resolved
        : resolved.replace(queryParameters: queryParameters);
  }

  Future<Map<String, String>> _authHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);
    final token = await _storage?.getString(StorageKeys.authToken);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  bool _shouldRetry(int? status) =>
      status == 429 || status == 503 || status == 502;

  Future<T> _withTimeout<T>(Future<T> future) {
    return future.timeout(AppConfig.receiveTimeout);
  }

  Future<http.Response> _retryingRequest(
    Future<http.Response> Function() fn,
  ) async {
    const maxRetries = 3;
    const baseDelayMs = 350;

    http.Response? lastResponse;
    Object? lastError;

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final res = await _withTimeout(fn());
        if (attempt < maxRetries && _shouldRetry(res.statusCode)) {
          await Future.delayed(
              Duration(milliseconds: baseDelayMs * (1 << attempt)));
          lastResponse = res;
          continue;
        }
        return res;
      } on TimeoutException catch (e) {
        lastError = e;
        if (attempt < maxRetries) {
          await Future.delayed(
              Duration(milliseconds: baseDelayMs * (1 << attempt)));
          continue;
        }
        rethrow;
      } on http.ClientException catch (e) {
        lastError = e;
        if (attempt < maxRetries) {
          await Future.delayed(
              Duration(milliseconds: baseDelayMs * (1 << attempt)));
          continue;
        }
        rethrow;
      }
    }
    if (lastResponse != null) return lastResponse;
    // En caso extremo, relanza el último error capturado.
    // ignore: only_throw_errors
    throw lastError ?? StateError('Error desconocido en _retryingRequest');
  }

  Future<http.Response> getRaw(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final uri = buildUri(path, query);
    final h = {...await _authHeaders(), ...?headers};
    return _retryingRequest(() => _http.get(uri, headers: h));
  }

  Future<http.Response> postRaw(
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    print('API SERVICE: postRaw called with path=$path');
    final uri = buildUri(path, query);
    print('API SERVICE: Final URI = $uri');
    final h = {...await _authHeaders(), ...?headers};
    final payload = body is String ? body : jsonEncode(body);
    print('API SERVICE: Payload = $payload');
    try {
      final response = await _retryingRequest(() => _http.post(uri, headers: h, body: payload));
      print('API SERVICE: Response status = ${response.statusCode}');
      print('API SERVICE: Response body = ${response.body}');
      return response;
    } catch (e) {
      print('API SERVICE: ERROR = $e');
      rethrow;
    }
  }

  Future<http.Response> putRaw(
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final uri = buildUri(path, query);
    final h = {...await _authHeaders(), ...?headers};
    final payload = body is String ? body : jsonEncode(body);
    return _retryingRequest(() => _http.put(uri, headers: h, body: payload));
  }

  Future<http.Response> deleteRaw(
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final uri = buildUri(path, query);
    final h = {...await _authHeaders(), ...?headers};
    if (body != null) {
      final payload = body is String ? body : jsonEncode(body);
      return _retryingRequest(() => _http.delete(uri, headers: h, body: payload));
    }
    return _retryingRequest(() => _http.delete(uri, headers: h));
  }

  Future<T> getJson<T>(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await getRaw(path, query: query, headers: headers);
    _ensureSuccess(res);
    return _decodeJson<T>(res.body);
  }

  Future<T> postJson<T>(
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await postRaw(path, body: body, query: query, headers: headers);
    _ensureSuccess(res);
    return _decodeJson<T>(res.body);
  }

  Future<T> putJson<T>(
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await putRaw(path, body: body, query: query, headers: headers);
    _ensureSuccess(res);
    return _decodeJson<T>(res.body);
  }

  Future<T> deleteJson<T>(
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await deleteRaw(path, body: body, query: query, headers: headers);
    _ensureSuccess(res);
    return _decodeJson<T>(res.body);
  }

  void _ensureSuccess(http.Response res) {
    final code = res.statusCode;
    if (code >= 200 && code < 300) return;
    throw http.ClientException('HTTP $code: ${res.body}', res.request?.url);
  }

  T _decodeJson<T>(String body) {
    final decoded = body.isEmpty ? null : jsonDecode(body);
    return decoded as T;
  }

  void close() {
    _client?.close();
    _client = null;
  }
}
