import 'package:mr_app/features/auth/domain/entities/auth.dart';

abstract class UserRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();
}