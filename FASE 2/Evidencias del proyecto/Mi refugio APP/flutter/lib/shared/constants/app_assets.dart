
class EmotionIcons {
  static const String basePath = 'assets/images/iconos/';
  
  // Emotion icons
  static const String emocion1 = '${basePath}emocion1.svg';
  static const String emocion2 = '${basePath}emocion2.svg';
  static const String emocion3 = '${basePath}emocion3.svg';
  static const String emocion4 = '${basePath}emocion4.svg';
  static const String emociones = '${basePath}emociones.svg';
  
  // Wellness icons
  static const String agua = '${basePath}agua.svg';
  static const String alimentacion = '${basePath}alimentacion.svg';
  static const String botella = '${basePath}botella.svg';
  static const String cuerpo = '${basePath}cuerpo.svg';
  static const String frutas = '${basePath}frutas.svg';
  static const String verduras = '${basePath}verduras.svg';
  static const String proteinas = '${basePath}proteinas.svg';
  
  // Mindfulness icons
  static const String meditar = '${basePath}meditar.svg';
  static const String mindfullness = '${basePath}mindfullness.svg';
  static const String respiracion = '${basePath}respiracion.svg';
  
  // Other icons
  static const String iaRecomienda = '${basePath}IA recomienda .svg';
  static const String fotoPerfil1 = '${basePath}foto perfil1.svg';
  static const String fotoPerfil2 = '${basePath}foto perfil2.svg';
  static const String googleLogo = '${basePath}google_logo.svg';
  
  // Map mood names to emotion icons
  static String getEmotionIcon(String mood) {
    final moodLower = mood.toLowerCase();
    if (moodLower.contains('calm') || moodLower.contains('paz') || moodLower.contains('tranquil')) {
      return emocion1;
    } else if (moodLower.contains('contento') || moodLower.contains('feliz') || moodLower.contains('alegr')) {
      return emocion2;
    } else if (moodLower.contains('ansioso') || moodLower.contains('estres') || moodLower.contains('preocup')) {
      return emocion3;
    } else if (moodLower.contains('triste') || moodLower.contains('melanc') || moodLower.contains('deprim')) {
      return emocion4;
    } else {
      return emociones; // Default icon
    }
  }
}

class MascotIcons {
  static const String basePath = 'assets/images/mascota/';
  
  static const String pose1 = '${basePath}Pose 1.svg';
  static const String pose2 = '${basePath}Pose 2.svg';
  static const String pose2b = '${basePath}Pose 2b.svg';
  static const String pose3 = '${basePath}Pose 3.svg';
  static const String pose4 = '${basePath}Pose 4.svg';
}

class LogoIcons {
  static const String basePath = 'assets/images/logo/';
  
  static const String logo = '${basePath}Logo.svg';
  static const String logoTexto = '${basePath}Logo Texto.svg';
}
