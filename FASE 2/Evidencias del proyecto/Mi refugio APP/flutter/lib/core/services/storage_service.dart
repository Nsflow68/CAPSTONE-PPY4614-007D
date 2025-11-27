import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Llaves comunes (usa namespacing consistente)
abstract final class StorageKeys {
  static const prefix = 'mr:'; // Mi Refugio
  static const authToken = '${prefix}auth_token';
  static const refreshToken = '${prefix}refresh_token';
  static const themeMode = '${prefix}theme_mode';
  static const onboardingCompleted = '${prefix}onboarding_completed';
  static const lastUserId = '${prefix}last_user_id';
  static const userCreatedAt = '${prefix}user_created_at';
  static const rewardSummary = '${prefix}reward_summary';
  static const profileAvatar = '${prefix}profile_avatar';
  static const profilePhone = '${prefix}profile_phone';
  static const profileNotifications = '${prefix}profile_notifications';
  static const profileName = '${prefix}profile_name';
  static const profileEmail = '${prefix}profile_email';
}

/// Provider de servicio (singleton)
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

/// Provider que asegura inicialización (útil en main antes de usar Storage)
final storageInitProvider = FutureProvider<void>((ref) {
  return ref.read(storageServiceProvider).initialize();
});

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;
  bool get isReady => _prefs != null;

  /// Inicializa una sola vez de manera segura
  Future<void> initialize() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _ensure() async {
    if (_prefs != null) return _prefs!;
    await initialize();
    return _prefs!;
  }

  // ========= GET =========
  Future<bool?> getBool(String key) async => (await _ensure()).getBool(key);
  Future<int?> getInt(String key) async => (await _ensure()).getInt(key);
  Future<double?> getDouble(String key) async =>
      (await _ensure()).getDouble(key);
  Future<String?> getString(String key) async =>
      (await _ensure()).getString(key);
  Future<List<String>?> getStringList(String key) async =>
      (await _ensure()).getStringList(key);

  /// JSON (Map/List) — devuelve null si no existe o si falla el parseo
  Future<T?> getJson<T>(String key) async {
    final raw = await getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded as T;
    } catch (_) {
      if (kDebugMode) print('StorageService.getJson: parse error for key=$key');
      return null;
    }
  }

  // ========= SET =========
  Future<bool> setBool(String key, bool value) async =>
      (await _ensure()).setBool(key, value);
  Future<bool> setInt(String key, int value) async =>
      (await _ensure()).setInt(key, value);
  Future<bool> setDouble(String key, double value) async =>
      (await _ensure()).setDouble(key, value);
  Future<bool> setString(String key, String value) async =>
      (await _ensure()).setString(key, value);
  Future<bool> setStringList(String key, List<String> value) async =>
      (await _ensure()).setStringList(key, value);

  /// Guarda JSON (Map/List) como string
  Future<bool> setJson(String key, Object value) async {
    try {
      final raw = jsonEncode(value);
      return setString(key, raw);
    } catch (_) {
      if (kDebugMode) {
        print('StorageService.setJson: encode error for key=$key');
      }
      return false;
    }
  }

  /// Upsert múltiple (útil para guardar varias preferencias juntas)
  Future<void> setMany(Map<String, Object?> entries) async {
    final sp = await _ensure();
    for (final e in entries.entries) {
      final k = e.key;
      final v = e.value;
      if (v == null) {
        await sp.remove(k);
      } else if (v is bool) {
        await sp.setBool(k, v);
      } else if (v is int) {
        await sp.setInt(k, v);
      } else if (v is double) {
        await sp.setDouble(k, v);
      } else if (v is String) {
        await sp.setString(k, v);
      } else if (v is List<String>) {
        await sp.setStringList(k, v);
      } else {
        // Para Map/List u otros -> JSON
        await sp.setString(k, jsonEncode(v));
      }
    }
  }

  // ========= MISC =========
  Future<bool> remove(String key) async => (await _ensure()).remove(key);
  Future<bool> clear() async => (await _ensure()).clear();
  Future<bool> containsKey(String key) async =>
      (await _ensure()).containsKey(key);
  Future<Set<String>> getKeys() async => (await _ensure()).getKeys();

  /// Limpia todas las llaves con el prefijo de Mi Refugio (sin tocar otras apps)
  Future<void> clearAppNamespace({String prefix = StorageKeys.prefix}) async {
    final sp = await _ensure();
    final keys = sp.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keys) {
      await sp.remove(k);
    }
  }
}
