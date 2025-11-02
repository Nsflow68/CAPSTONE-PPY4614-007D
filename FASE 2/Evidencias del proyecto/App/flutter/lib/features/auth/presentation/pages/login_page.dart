import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mi_refugio_app/core/services/theme_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: const ['email']);

  bool _isAuthenticating = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isAuthenticating) {
      return;
    }
    setState(() => _isAuthenticating = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _isAuthenticating = false);
    context.go('/home');
  }

  Future<void> _signInWithGoogle() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account != null && mounted) {
        setState(() => _isAuthenticating = false);
        context.go('/home');
        return;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo iniciar sesión con Google. Inténtalo de nuevo.',
            ),
          ),
        );
      }
    }
    if (mounted) {
      setState(() => _isAuthenticating = false);
    }
  }

  void _continueAsGuest() {
    if (_isAuthenticating) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    InputDecoration fieldDecoration({
      required String label,
      String? hint,
      IconData? icon,
    }) {
      final primary = theme.colorScheme.primary;
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: primary.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primary, width: 1.4),
        ),
      );
    }

    Widget authenticatingIndicator() => const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2.3),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDF8F1), Color(0xFFF6F1FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14352F44),
                        blurRadius: 18,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE7DCFF), Color(0xFFF6ECFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/branding/logo_primary.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Bienvenido a Mi Refugio',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu espacio seguro para cuidar tu bienestar emocional.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Image.asset(
                          'assets/images/mascot/pose2.png',
                          height: 110,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 26),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: fieldDecoration(
                            label: 'Correo electrónico',
                            hint: 'nombre@correo.com',
                            icon: Icons.mail_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            if (!value.contains('@')) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: fieldDecoration(
                            label: 'Contraseña',
                            icon: Icons.lock_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                            ),
                            child: const Text('¿Olvidaste tu contraseña?'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: _isAuthenticating ? null : _signIn,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            textStyle: const TextStyle(fontSize: 17),
                          ),
                          child: _isAuthenticating
                              ? authenticatingIndicator()
                              : const Text('Iniciar sesión'),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _isAuthenticating
                              ? null
                              : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            side: BorderSide(color: Colors.grey.shade300),
                            backgroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          icon: SvgPicture.asset(
                            'assets/icons/google_logo.svg',
                            height: 22,
                            width: 22,
                          ),
                          label: const Text('Continuar con Google'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _isAuthenticating
                              ? null
                              : _continueAsGuest,
                          icon: const Icon(Icons.explore_rounded),
                          label: const Text('Ingresar como invitado'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Modo oscuro',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 12),
                            Switch(
                              value:
                                  ThemeController.instance.mode ==
                                  ThemeMode.dark,
                              onChanged: (_) =>
                                  ThemeController.instance.toggle(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
