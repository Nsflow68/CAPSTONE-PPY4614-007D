import 'dart:async';

import 'package:mi_refugio_app/core/services/storage_service.dart';
import 'package:mi_refugio_app/features/auth/application/auth_state.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class AuthRepository {
  AuthRepository(this._storage);

  final StorageService _storage;

  Future<bool> isAuthenticated() async {
    return (await _storage.getString(StorageKeys.authToken))?.isNotEmpty ??
        false;
  }

  Future<AuthUser?> getCurrentUser() async {
    final email = await _storage.getString(StorageKeys.lastUserId);
    if (email == null) return null;
    final createdRaw = await _storage.getString(StorageKeys.userCreatedAt);
    final createdAt = createdRaw != null ? DateTime.tryParse(createdRaw) : null;
    return AuthUser(
      id: email,
      email: email,
      name: 'Mi Refugio',
      createdAt: createdAt,
    );
  }

  Future<AuthUser> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final user = AuthUser(
      id: uuid.v4(),
      email: email,
      name: email.split('@').first,
      createdAt: DateTime.now(),
    );
    await _storage.setMany({
      StorageKeys.authToken: 'token-${user.id}',
      StorageKeys.lastUserId: user.email,
      StorageKeys.userCreatedAt: user.createdAt!.toIso8601String(),
    });
    return user;
  }

  Future<AuthUser> loginWithGoogle(String token) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final user = AuthUser(
      id: uuid.v4(),
      email: 'google_user@mirefugio.cl',
      name: 'Cuenta Google',
      createdAt: DateTime.now(),
    );
    await _storage.setMany({
      StorageKeys.authToken: token,
      StorageKeys.lastUserId: user.email,
      StorageKeys.userCreatedAt: user.createdAt!.toIso8601String(),
    });
    return user;
  }

  Future<AuthUser> loginAsGuest() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final user = AuthUser(
      id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@mirefugio.cl',
      name: 'Invitado',
      createdAt: DateTime.now(),
    );
    await _storage.setMany({
      StorageKeys.authToken: 'guest-token',
      StorageKeys.lastUserId: user.email,
      StorageKeys.userCreatedAt: user.createdAt!.toIso8601String(),
    });
    return user;
  }

  Future<void> logout() async {
    await _storage.setMany({
      StorageKeys.authToken: null,
      StorageKeys.lastUserId: null,
      StorageKeys.userCreatedAt: null,
    });
  }
}
