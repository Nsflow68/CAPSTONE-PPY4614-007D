import 'package:mr_app/features/auth/domain/entities/auth.dart';
import 'package:mr_app/features/auth/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Implement real authentication logic
      await Future.delayed(const Duration(seconds: 2)); // Simulation
      return User(
        id: '1',
        name: 'Usuario Demo',
        email: email,
      );
    } catch (e) {
      throw Exception('Error during login: ${e.toString()}');
    }
  }

  @override
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Implement real registration logic
      await Future.delayed(const Duration(seconds: 2)); // Simulation
      return User(
        id: '1',
        name: name,
        email: email,
      );
    } catch (e) {
      throw Exception('Error during sign up: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // TODO: Implement real logout logic
      await Future.delayed(const Duration(seconds: 1)); // Simulation
    } catch (e) {
      throw Exception('Error during logout: ${e.toString()}');
    }
  }
}