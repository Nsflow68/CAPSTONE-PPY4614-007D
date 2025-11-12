import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final DateTime? createdAt;

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, createdAt];
}

sealed class AuthState {
  const AuthState();

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(AuthUser user) authenticated,
    required T Function(String message) error,
  }) {
    final state = this;
    if (state is AuthInitial) return initial();
    if (state is AuthLoading) return loading();
    if (state is AuthAuthenticated) return authenticated(state.user);
    if (state is AuthError) return error(state.message);
    throw StateError('Estado de autenticaci\u00f3n no soportado: $runtimeType');
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(AuthUser user)? authenticated,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    final state = this;
    if (state is AuthInitial) {
      return initial != null ? initial() : orElse();
    }
    if (state is AuthLoading) {
      return loading != null ? loading() : orElse();
    }
    if (state is AuthAuthenticated) {
      return authenticated != null ? authenticated(state.user) : orElse();
    }
    if (state is AuthError) {
      return error != null ? error(state.message) : orElse();
    }
    return orElse();
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(AuthUser user)? authenticated,
    T Function(String message)? error,
  }) {
    final state = this;
    if (state is AuthInitial) return initial?.call();
    if (state is AuthLoading) return loading?.call();
    if (state is AuthAuthenticated) return authenticated?.call(state.user);
    if (state is AuthError) return error?.call(state.message);
    return null;
  }
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AuthUser user;
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}
