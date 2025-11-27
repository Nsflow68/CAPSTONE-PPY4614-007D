import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';

class StorageKeys {
  static const prefix = 'mr:';
  static const themeMode = '${prefix}theme_mode';
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(storageServiceProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(ThemeMode.light) {
    _load();
  }

  final StorageService _storage;

  Future<void> _load() async {
    final v = await _storage.getString(StorageKeys.themeMode);
    if (v == null) return;
    switch (v) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
        state = ThemeMode.system;
        break;
      default:
        state = ThemeMode.light;
    }
  }

  Future<void> toggle() async {
    await setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await _storage.setString(StorageKeys.themeMode, mode.name);
  }
}

class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  Future<void> initialize() async {
    final v = await StorageService.instance.getString(StorageKeys.themeMode);
    if (v != null) {
      switch (v) {
        case 'light':
          _mode = ThemeMode.light;
          break;
        case 'dark':
          _mode = ThemeMode.dark;
          break;
        case 'system':
          _mode = ThemeMode.system;
          break;
        default:
          _mode = ThemeMode.light;
      }
    }
    notifyListeners();
  }

  Future<void> toggle() async {
    await setMode(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    await StorageService.instance.setString(StorageKeys.themeMode, mode.name);
    notifyListeners();
  }
}
