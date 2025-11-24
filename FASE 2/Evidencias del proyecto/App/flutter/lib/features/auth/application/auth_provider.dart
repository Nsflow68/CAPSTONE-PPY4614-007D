import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/core/services/storage_service.dart';
import 'package:mi_refugio_app/core/types/result.dart';
import 'package:mi_refugio_app/features/auth/application/auth_state.dart';
import 'package:mi_refugio_app/features/auth/data/models/auth_failure.dart';
import 'package:mi_refugio_app/features/auth/data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AuthRepository(storage);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    final result = await _repository.loginWithCredentials(
      email: email,
      password: password,
    );
    _handleResult(result);
  }

  Future<void> loginWithGoogle(String idToken) async {
    state = const AuthLoading();
    final result = await _repository.loginWithGoogle(idToken);
    _handleResult(result);
  }

  Future<void> loginAsGuest() async {
    state = const AuthLoading();
    final result = await _repository.loginAsGuest();
    _handleResult(result);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthInitial();
  }

  void _handleResult(Result<AuthUser, AuthFailure> result) {
    result.when(
      success: (user) => state = AuthAuthenticated(user),
      failure: (failure) => state = AuthError(failure.readableMessage()),
    );
  }
}
