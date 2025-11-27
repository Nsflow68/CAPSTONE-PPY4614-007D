enum AuthFailureType {
  network,
  invalidCredentials,
  unauthorized,
  server,
  unknown,
}

class AuthFailure {
  const AuthFailure(this.type, {this.message});

  final AuthFailureType type;
  final String? message;

  String readableMessage() {
    switch (type) {
      case AuthFailureType.network:
        return 'Revisa tu conexión e inténtalo nuevamente.';
      case AuthFailureType.invalidCredentials:
        return 'Correo o contraseña incorrectos.';
      case AuthFailureType.unauthorized:
        return 'Sesión no autorizada. Vuelve a iniciar sesión.';
      case AuthFailureType.server:
        return 'El servicio no respondió. Intenta más tarde.';
      case AuthFailureType.unknown:
        return message ?? 'Ocurrió un error inesperado.';
    }
  }
}
