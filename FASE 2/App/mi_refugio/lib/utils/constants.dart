import 'package:flutter/material.dart';

/// Constantes de colores y estilos para Mi Refugio
class AppColors {
  // Colores principales
  static const Color primary = Color(0xFF6B9BD1);
  static const Color secondary = Color(0xFF89CFF0);
  static const Color tertiary = Color(0xFFB4E7CE);
  static const Color accent = Color(0xFF9DCBBA);
  
  // Colores de estado emocional (para uso futuro)
  static const Color happy = Color(0xFFFFD700);
  static const Color sad = Color(0xFF6B9BD1);
  static const Color anxious = Color(0xFFFF6B6B);
  static const Color calm = Color(0xFFB4E7CE);
  static const Color angry = Color(0xFFFF4757);
  static const Color tired = Color(0xFF9E9E9E);
  
  // Colores neutros
  static const Color white = Colors.white;
  static const Color black = Colors.black87;
  static const Color grey = Color(0xFF757575);
  static const Color greyLight = Color(0xFFE0E0E0);
  
  // Gradientes
  static const List<Color> primaryGradient = [
    Color(0xFF6B9BD1),
    Color(0xFF89CFF0),
    Color(0xFFB4E7CE),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFFB4E7CE),
    Color(0xFF9DCBBA),
  ];
}

/// Constantes de estilos de texto
class AppTextStyles {
  // TÃ­tulos
  static const TextStyle h1 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  // Cuerpo
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  // Botones
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  
  // SubtÃ­tulos
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
}

/// Constantes de espaciado
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
}

/// Constantes de radio de bordes
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double circle = 100.0;
}

/// Constantes de elevaciÃ³n/sombras
class AppElevation {
  static const double none = 0.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 16.0;
}

/// Constantes de animaciÃ³n
class AppAnimation {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 1000);
  
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bouncy = Curves.easeOutBack;
}

/// Constantes de iconos segÃºn tipo de emociÃ³n
class AppIcons {
  static const IconData happy = Icons.sentiment_very_satisfied;
  static const IconData sad = Icons.sentiment_dissatisfied;
  static const IconData anxious = Icons.sentiment_neutral;
  static const IconData calm = Icons.spa;
  static const IconData angry = Icons.sentiment_very_dissatisfied;
  static const IconData tired = Icons.bedtime;
  
  // Iconos de funcionalidades
  static const IconData chat = Icons.chat_bubble_outline;
  static const IconData diary = Icons.book_outlined;
  static const IconData exercise = Icons.self_improvement;
  static const IconData resources = Icons.library_books_outlined;
  static const IconData profile = Icons.person_outline;
  static const IconData settings = Icons.settings_outlined;
}

/// Constantes de configuraciÃ³n
class AppConfig {
  static const String appName = 'Mi Refugio';
  static const String appSlogan = 'Tu espacio de bienestar emocional';
  
  // Tiempos
  static const int splashDuration = 3; // segundos
  static const int tokenExpiration = 24; // horas
  
  // URLs (por configurar segÃºn backend)
  static const String baseUrl = 'https://api.mirefugio.cl';
  static const String apiVersion = '/api/v1';
}
