part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final AuthCredentials credentials;

  const LoginRequested({required this.credentials});

  @override
  List<Object> get props => [credentials];
}

class SignUpRequested extends AuthEvent {
  final String name;
  final AuthCredentials credentials;

  const SignUpRequested({
    required this.name,
    required this.credentials,
  });

  @override
  List<Object> get props => [name, credentials];
}

class LogoutRequested extends AuthEvent {}