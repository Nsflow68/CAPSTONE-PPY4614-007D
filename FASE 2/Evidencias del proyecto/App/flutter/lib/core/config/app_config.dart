class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'MI_REFUGIO_API',
    defaultValue: 'https://api.mi-refugio-dev.us-east-1.amazonaws.com',
  );

  static const Duration requestTimeout = Duration(seconds: 6);
}
