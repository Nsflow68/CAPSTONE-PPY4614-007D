class AppConfig {
  AppConfig._();

  static String _envString(String key, {required String defaultValue}) {
    const env = String.fromEnvironment;
    final v = env(key, defaultValue: defaultValue).trim();
    return v.isEmpty ? defaultValue : v;
  }

  static bool _envBool(String key, {required bool defaultValue}) {
    const env = String.fromEnvironment;
    final v = env(key, defaultValue: defaultValue.toString()).trim().toLowerCase();
    return v == 'true' || v == '1' || v == 'yes' || v == 'si';
  }

  static int _envInt(String key, {required int defaultValue}) {
    const env = String.fromEnvironment;
    final v = env(key, defaultValue: defaultValue.toString()).trim();
    return int.tryParse(v) ?? defaultValue;
  }

  static final env = _envString('APP_ENV', defaultValue: 'dev');

  static final useNestBackend = _envBool('USE_NEST_BACKEND', defaultValue: true);

  static final apiBaseUrl = useNestBackend
      ? _envString(
          'NEST_API_BASE_URL',
          defaultValue: 'http://localhost:3001/api/',
        )
      : _envString(
          'API_BASE_URL',
          defaultValue: 'http://localhost:8000/',
        );
  static final apiLogging = _envBool('API_LOGGING', defaultValue: true);
  static final connectTimeout = Duration(seconds: _envInt('CONNECT_TIMEOUT_S', defaultValue: 10));
  static final sendTimeout = Duration(seconds: _envInt('SEND_TIMEOUT_S', defaultValue: 10));
  static final receiveTimeout = Duration(seconds: _envInt('RECEIVE_TIMEOUT_S', defaultValue: 300));

  static final dbHost = _envString(
    'DB_HOST',
    defaultValue: 'mirefugio.c9ie2ckqg3rt.us-east-2.rds.amazonaws.com',
  );
  static final dbPort = _envInt('DB_PORT', defaultValue: 5432);
  static final dbName = _envString('DB_NAME', defaultValue: 'mirefugio');
  static final dbUser = _envString('DB_USER', defaultValue: 'mirefugio_owner');
  static final dbPassword = _envString('DB_PASSWORD', defaultValue: 'Mirefugio2025!');

  static final llmBaseUrl = _envString(
    'LLM_BASE_URL',
    defaultValue: 'http://127.0.0.1:11434',
  );
  static final llmModel = _envString('LLM_MODEL', defaultValue: 'llama3');
  static final llmTimeout = Duration(milliseconds: _envInt('LLM_TIMEOUT_MS', defaultValue: 60000));
  static final llmStreamEnabled = _envBool('LLM_STREAM_ENABLED', defaultValue: true);

  static final enableSSLPinning = _envBool('ENABLE_SSL_PINNING', defaultValue: false);
  static final enableBiometricAuth = _envBool('ENABLE_BIOMETRIC_AUTH', defaultValue: true);

  static final maxImageCacheSize = _envInt('MAX_IMAGE_CACHE_SIZE_MB', defaultValue: 100);
  static final enableAnalytics = _envBool('ENABLE_ANALYTICS', defaultValue: false);
}
