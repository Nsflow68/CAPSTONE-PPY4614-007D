import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dailyMessageServiceProvider = Provider<DailyMessageService>((ref) {
  return DailyMessageService();
});

class DailyMessageService {
  static const String _lastMessageDateKey = 'last_message_date';
  static const String _lastMessageIndexKey = 'last_message_index';

  final List<String> _messages = [
    'La calma no es la ausencia de caos, sino la paz en medio de él.',
    'Cada paso cuenta, no importa cuán pequeño sea.',
    'Tu bienestar es tu prioridad número uno hoy.',
    'Respira profundo. Estás exactamente donde necesitas estar.',
    'La gratitud transforma lo que tenemos en suficiente.',
    'Eres más fuerte de lo que crees y más capaz de lo que imaginas.',
    'Hoy es un buen día para cuidar de ti.',
    'Permítete descansar. Es parte del proceso de crecer.',
    'Tus emociones son válidas y merecen ser escuchadas.',
    'Confía en el proceso. Todo llega a su tiempo.',
  ];

  Future<String> getDailyMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';

    final lastDate = prefs.getString(_lastMessageDateKey);
    int index;

    if (lastDate != dateKey) {
      // New day, pick a new random message
      index = Random().nextInt(_messages.length);
      await prefs.setString(_lastMessageDateKey, dateKey);
      await prefs.setInt(_lastMessageIndexKey, index);
    } else {
      // Same day, retrieve stored index
      index = prefs.getInt(_lastMessageIndexKey) ?? 0;
    }

    return _messages[index];
  }
}
