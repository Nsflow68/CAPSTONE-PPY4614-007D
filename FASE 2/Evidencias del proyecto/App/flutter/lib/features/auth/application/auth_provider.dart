import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/core/services/storage_service.dart';
import 'package:mi_refugio_app/features/auth/application/auth_state.dart';
import 'package:mi_refugio_app/features/auth/data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AuthRepository(storage);
});

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await _repository.loginWithCredentials(
        email: email,
        password: password,
      );
      state = AuthAuthenticated(user);
    } catch (e) {
      state = AuthError('No pudimos iniciar sesión. Intenta nuevamente.');
    }
  }

  Future<void> loginWithGoogle(String idToken) async {
    state = const AuthLoading();
    try {
      final user = await _repository.loginWithGoogle(idToken);
      state = AuthAuthenticated(user);
    } catch (_) {
      state = AuthError('Ocurrió un problema con Google Sign-In.');
    }
  }

  Future<void> loginAsGuest() async {
    state = const AuthLoading();
    final user = await _repository.loginAsGuest();
    state = AuthAuthenticated(user);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthInitial();
  }
}
