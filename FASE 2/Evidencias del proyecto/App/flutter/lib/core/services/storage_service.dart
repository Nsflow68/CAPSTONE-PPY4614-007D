import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getString(String key) => _prefs?.getString(key);
  Future<bool> setString(String key, String value) async =>
      await _prefs?.setString(key, value) ?? false;
}
