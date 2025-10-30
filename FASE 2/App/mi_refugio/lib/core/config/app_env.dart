class AppEnv {
  static const apiBase = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
  static const chatHttp = String.fromEnvironment('CHAT_HTTP_URL', defaultValue: 'http://localhost:3000/chat');
}
