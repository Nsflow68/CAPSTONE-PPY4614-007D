enum DiaryFailureType {
  network,
  invalidData,
  unauthorized,
  notFound,
  server,
  unknown,
}

class DiaryFailure {
  const DiaryFailure(this.type, {this.message});

  final DiaryFailureType type;
  final String? message;

  String readableMessage() {
    switch (type) {
      case DiaryFailureType.network:
        return 'Revisa tu conexión e inténtalo nuevamente.';
      case DiaryFailureType.invalidData:
        return 'Los datos enviados no son válidos.';
      case DiaryFailureType.unauthorized:
        return 'Sesión expirada o no autorizada. Vuelve a iniciar sesión.';
      case DiaryFailureType.notFound:
        return 'El registro no existe o fue eliminado.';
      case DiaryFailureType.server:
        return 'El servicio de diario no respondió. Intenta más tarde.';
      case DiaryFailureType.unknown:
        return message ?? 'Ocurrió un error inesperado.';
    }
  }
}
