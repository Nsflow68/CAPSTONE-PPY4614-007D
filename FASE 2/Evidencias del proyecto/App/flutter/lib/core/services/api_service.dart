import 'package:http/http.dart' as http;
import 'package:mi_refugio_app/core/config/app_config.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  http.Client? _client;
  Map<String, String> _defaultHeaders = const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void initialize({http.Client? client}) {
    _client?.close();
    _client = client ?? http.Client();
  }

  http.Client get client => _client ??= http.Client();

  Map<String, String> get defaultHeaders => Map.unmodifiable(_defaultHeaders);

  void setDefaultHeaders(Map<String, String> headers) {
    _defaultHeaders = Map.of(headers);
  }

  Uri buildUri(String path, [Map<String, String>? queryParameters]) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    final normalisedPath = path.startsWith('/') ? path.substring(1) : path;
    final resolved = base.resolve(normalisedPath);
    if (queryParameters == null) return resolved;
    return resolved.replace(queryParameters: queryParameters);
  }
}
