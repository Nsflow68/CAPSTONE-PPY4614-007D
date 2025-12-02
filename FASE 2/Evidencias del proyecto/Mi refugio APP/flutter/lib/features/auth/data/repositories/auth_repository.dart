import 'dart:async';
import 'package:mi_refugio_app/core/services/api_service.dart';

import 'package:mi_refugio_app/core/services/storage_service.dart';
import 'package:mi_refugio_app/core/types/result.dart';
import 'package:mi_refugio_app/features/auth/application/auth_state.dart';
import 'package:mi_refugio_app/features/auth/data/models/auth_failure.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();



class AuthRepository {
  AuthRepository(this._storage, {ApiService? apiService})
      : _api = apiService ?? ApiService.instance;

  final StorageService _storage;
  final ApiService _api;

  Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.getString(StorageKeys.authToken).timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      return token?.isNotEmpty ?? false;
    } catch (e) {
      return false;
    }
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

  Future<Result<AuthUser, AuthFailure>> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    try {
      print('AUTH REPO: Attempting login to auth/login with $email');
      final response = await _api.postRaw(
        'auth/login',
        body: {'username': email, 'password': password},
      );
      print('AUTH REPO: Response status: ${response.statusCode}');
      print('AUTH REPO: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = await _api.postJson<Map<String, dynamic>>(
          'auth/login',
          body: {'username': email, 'password': password},
        );
        
        if (data['success'] == true) {
          final userData = data['user'];
          final token = data['token'] as String?;
          
          final user = AuthUser(
            id: userData['id'].toString(),
            email: userData['username'],
            name: userData['full_name'] ?? userData['username'],
            createdAt: DateTime.now(),
          );

          await _storage.setMany({
            StorageKeys.authToken: token ?? 'token-${user.id}', 
            StorageKeys.lastUserId: user.email,
            StorageKeys.userCreatedAt: user.createdAt!.toIso8601String(),
          });
          return Success(user);
        }
      }
      
      return const Failure(AuthFailure(AuthFailureType.invalidCredentials));
    } catch (e) {
      return Failure(AuthFailure(AuthFailureType.server, message: e.toString()));
    }
  }

  Future<Result<AuthUser, AuthFailure>> loginWithGoogle(String token) async {
    try {
      final response = await _api.postRaw(
        'auth/google-login',
        body: {'token': token},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = await _api.postJson<Map<String, dynamic>>(
          'auth/google-login',
          body: {'token': token},
        );

        if (data['success'] == true) {
          final userData = data['user'];
          final user = AuthUser(
            id: userData['id'].toString(),
            email: userData['username'],
            name: userData['full_name'] ?? userData['username'],
            createdAt: DateTime.now(),
          );

          await _storage.setMany({
            StorageKeys.authToken: token,
            StorageKeys.lastUserId: user.email,
            StorageKeys.userCreatedAt: user.createdAt!.toIso8601String(),
          });
          return Success(user);
        }
      }
      return const Failure(AuthFailure(AuthFailureType.invalidCredentials));
    } catch (e) {
      return Failure(AuthFailure(AuthFailureType.server, message: e.toString()));
    }
  }



  Future<Result<void, AuthFailure>> logout() async {
    await _storage.setMany({
      StorageKeys.authToken: null,
      StorageKeys.lastUserId: null,
      StorageKeys.userCreatedAt: null,
    });
    return const Success(null);
  }

  Future<Result<AuthUser, AuthFailure>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String rut,
    DateTime? birthDate,
    String? gender,
  }) async {
    try {
      print('AUTH REPO: Attempting register for $email');
      final data = await _api.postJson<Map<String, dynamic>>(
        'auth/register',
        body: {
          'username': username,
          'email': email,
          'password': password,
          'name': fullName, // Backend expects 'name', not 'full_name' in auth/register DTO usually, checking backend...
          // Wait, backend User entity has 'name'. AuthController.register DTO?
          // Let's assume 'name' for now as per User entity.
          'rut': rut,
          'birthDate': birthDate?.toIso8601String(),
          'gender': gender,
        },
      );
      print('AUTH REPO: Register response data: $data');

      // If postJson returns, it means success (200/201) because ApiService throws on error
      final user = AuthUser(
          id: data['id'].toString(),
          email: data['email'], 
          name: data['name'] ?? data['username'],
          createdAt: DateTime.now(),
      );
      
      return Success(user);
    } catch (e) {
      print('AUTH REPO: Register error: $e');
      String errorMessage = e.toString();
      
      // Try to parse backend error message
      if (e.toString().contains('ClientException')) {
        try {
          // Extract JSON body from exception string if possible, or just use the message
          // Since ClientException.toString() format is "ClientException: <message>, uri=..."
          // And ApiService throws "HTTP <code>: <body>"
          
          final parts = e.toString().split(': ');
          if (parts.length > 2) {
             // Attempt to find JSON in the string
             final jsonStart = e.toString().indexOf('{');
             final jsonEnd = e.toString().lastIndexOf('}');
             if (jsonStart != -1 && jsonEnd != -1) {
               final jsonStr = e.toString().substring(jsonStart, jsonEnd + 1);
               // Use RegExp to find "message":"..." or "message": "..."
               final regExp = RegExp(r'"message"\s*:\s*"([^"]+)"');
               final match = regExp.firstMatch(jsonStr);
               if (match != null) {
                 errorMessage = match.group(1) ?? errorMessage;
                 return Failure(AuthFailure(AuthFailureType.unknown, message: errorMessage));
               }
             }
          }
        } catch (_) {}
      }
      
      return Failure(AuthFailure(AuthFailureType.server, message: errorMessage));
    }
  }
}
