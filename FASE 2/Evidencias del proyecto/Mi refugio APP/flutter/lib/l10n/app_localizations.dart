import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations._();

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('es'), Locale('en')];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations._();
  }

  String get loginWelcomeTitle => 'Mi Refugio te da la bienvenida';
  String get loginWelcomeSubtitle =>
      'Un espacio sensorial para acompañarte en cada emoción.';
  String get loginEmailLabel => 'Correo electrónico';
  String get loginEmailHint => 'usuario@ejemplo.com';
  String get loginEmailEmptyError => 'Ingresa tu correo';
  String get loginEmailInvalidError => 'El correo no es válido';
  String get loginPasswordLabel => 'Contraseña';
  String get loginPasswordEmptyError => 'Ingresa tu contraseña';
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';
  String get loginPrimaryButton => 'Iniciar sesión';
  String get loginSocialDivider => 'o continúa con';
  String get loginGoogleButton => 'Continuar con Google';
  String get loginContinueGuest => 'Explorar como invitado';
  String get loginNoAccountQuestion => '¿No tienes cuenta?';
  String get loginRegisterAction => 'Regístrate aquí';
  String get loginDarkModeLabel => 'Modo oscuro';
  String get loginGoogleError =>
      'No pudimos conectar con tu cuenta de Google. Intenta nuevamente.';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return const AppLocalizations._();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
