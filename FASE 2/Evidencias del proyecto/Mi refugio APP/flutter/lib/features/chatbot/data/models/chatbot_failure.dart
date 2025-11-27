enum ChatbotFailureType {
  network,
  invalidData,
  unauthorized,
  notFound,
  server,
  unknown,
}

class ChatbotFailure {
  const ChatbotFailure(this.type, {this.message});

  final ChatbotFailureType type;
  final String? message;

  String readableMessage() {
    switch (type) {
      case ChatbotFailureType.network:
        return 'Revisa tu conexión e inténtalo nuevamente.';
      case ChatbotFailureType.invalidData:
        return 'El mensaje enviado no es válido.';
      case ChatbotFailureType.unauthorized:
        return 'Sesión expirada o no autorizada. Vuelve a iniciar sesión.';
      case ChatbotFailureType.notFound:
        return 'El servicio de chat no está disponible.';
      case ChatbotFailureType.server:
        return 'El servicio de chat no respondió. Intenta más tarde.';
      case ChatbotFailureType.unknown:
        return message ?? 'Ocurrió un error inesperado.';
    }
  }
}
