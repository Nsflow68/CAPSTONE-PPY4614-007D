import 'dart:math';

import 'package:mi_refugio_app/core/config/app_config.dart';
import 'package:mi_refugio_app/core/services/api_service.dart';
import 'package:mi_refugio_app/features/chatbot/data/models/chat_message_model.dart';

class RefuBotService {
  RefuBotService({ApiService? api}) : _api = api ?? ApiService.instance;

  final ApiService _api;
  final _random = Random();

  Future<ChatReplyPayload> sendMessage({
    required String prompt,
    required List<ChatMessageModel> history,
  }) async {
    final payload = {
      'prompt': prompt,
      'model': AppConfig.llmModel,
      'history': history.map((m) => m.toJson()).toList(),
    };

    try {
      final data =
          await _api.postJson<Map<String, dynamic>>('/chatbot/messages', body: payload);
      return ChatReplyPayload.fromJson(data);
    } catch (_) {
      return _offlineReply(prompt, history);
    }
  }

  ChatReplyPayload _offlineReply(
    String prompt,
    List<ChatMessageModel> history,
  ) {
    final normalized = prompt.toLowerCase();

    if (normalized.contains('ansiedad') || normalized.contains('estres')) {
      return ChatReplyPayload(
        response:
            'Vamos paso a paso. Inhala en 4 tiempos, sostén 2 y exhala en 6. ¿Qué sensación notas en tu cuerpo después de intentarlo?',
        followUps: const [
          'Guíame con otra respiración',
          'Necesito una frase para calmar mi mente',
          'Quiero hablar con una persona de apoyo',
        ],
        calmScore: 0.35,
        focus: 'Respiración cuadrada',
        practice: 'Respira en 4 tiempos, sostén 2, exhala en 6. Repite 4 veces.',
      );
    }

    if (normalized.contains('triste') || normalized.contains('desanimado')) {
      return ChatReplyPayload(
        response:
            'Validemos esa emoción: sentirte triste es humano. ¿Te gustaría hacer un ejercicio de gratitud o prefieres que te comparta un recurso profesional?',
        followUps: const [
          'Compárteme un recurso profesional cercano',
          'Dame un ejercicio de gratitud',
          'Necesito escribir lo que siento',
        ],
        calmScore: 0.42,
        focus: 'Gratitud guiada',
        practice: 'Escribe tres cosas pequeñas que valoraste hoy y cómo te hicieron sentir.',
      );
    }

    if (normalized.contains('enojo') || normalized.contains('frustrado')) {
      return ChatReplyPayload(
        response:
            'Cuando la energía sube, ayuda mover el cuerpo. ¿Te parece si hacemos una liberación con respiración + estiramiento?',
        followUps: const [
          'Sí, guíame con movimiento',
          'Prefiero escribir lo que me molestó',
          'Necesito enviar un mensaje de disculpa',
        ],
        calmScore: 0.38,
        focus: 'Liberación corporal',
        practice: 'Sacude brazos y manos por 30 segundos, luego exhala con sonido para liberar tensión.',
      );
    }

    final options = [
      ChatReplyPayload(
        response:
            'Estoy aquí para acompañarte. ¿Quieres que preparemos una mini rutina (respirar, escribir y agradecer) para este momento?',
        followUps: const [
          'Hagamos la mini rutina',
          'Solo quiero conversar',
          'Recomiéndame un audio corto',
        ],
        calmScore: 0.55,
        focus: 'Rutina 3 pasos',
        practice: 'Respira profundo 3 veces, escribe una frase y cierra con algo que agradeces.',
      ),
      ChatReplyPayload(
        response:
            'Gracias por confiar en Refu. Puedo darte técnicas de respiración, grounding o compartir contactos profesionales. ¿Qué necesitas ahora?',
        followUps: const [
          'Necesito grounding',
          'Quiero ver contactos profesionales',
          'Estoy bien, gracias Refu',
        ],
        calmScore: 0.6,
        focus: 'Chequeo emocional',
        practice: 'Observa 5 cosas que ves, 4 que sientes, 3 que escuchas, 2 que hueles y 1 que saboreas.',
      ),
    ];

    return options[_random.nextInt(options.length)];
  }
}
