import 'dart:async';



import 'package:flutter/material.dart';



import 'package:flutter_riverpod/flutter_riverpod.dart';



import 'package:flutter_svg/flutter_svg.dart';



import 'package:go_router/go_router.dart';



import 'package:google_sign_in/google_sign_in.dart';



import 'package:mi_refugio_app/core/services/theme_controller.dart';
import 'package:mi_refugio_app/l10n/app_localizations.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';
import 'package:mi_refugio_app/shared/constants/app_assets.dart';
import 'package:mi_refugio_app/shared/constants/app_shadows.dart';



import 'package:mi_refugio_app/shared/utils/responsive_layout.dart';



import '../../application/auth_provider.dart';



import '../../application/auth_state.dart';



class LoginPage extends ConsumerStatefulWidget {

  const LoginPage({super.key});



  @override

  ConsumerState<LoginPage> createState() => _LoginPageState();

}



class _LoginPageState extends ConsumerState<LoginPage> {

  final _formKey = GlobalKey<FormState>();



  final _email = TextEditingController();



  final _password = TextEditingController();



  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: const ['email']);



  bool _obscurePassword = true;



  bool _isGoogleLoading = false;



  int _quoteIndex = 0;



  Timer? _quoteTimer;



  static const _quotes = [

    'Respira. Cada emoción merece ser escuchada.',

    'Tu historia importa incluso en los días grises.',

    'No necesitas estar bien para empezar; solo ser honesto contigo.',

    'Comparte cómo te sientes y deja que el camino sea más liviano.',

  ];



  @override

  void initState() {

    super.initState();



    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (_) {

      if (!mounted) return;



      setState(() => _quoteIndex = (_quoteIndex + 1) % _quotes.length);

    });

  }



  @override

  void dispose() {

    _email.dispose();



    _password.dispose();



    _quoteTimer?.cancel();



    super.dispose();

  }



  Future<void> _handleCredentialsLogin() async {

    if (!(_formKey.currentState?.validate() ?? false) || _isGoogleLoading) {

      return;

    }



    print('LOGIN PAGE: Login button pressed');
    await ref
        .read(authProvider.notifier)
        .login(_email.text.trim(), _password.text);

  }



  Future<void> _handleGoogleLogin() async {

    if (_isGoogleLoading) return;



    setState(() => _isGoogleLoading = true);



    try {

      final account = await _googleSignIn.signIn();



      if (!mounted) return;



      if (account == null) return;



      final googleAuth = await account.authentication;



      final idToken = googleAuth.idToken;



      if (idToken == null || idToken.isEmpty) {

        throw const FormatException('missing_id_token');

      }



      await ref.read(authProvider.notifier).loginWithGoogle(idToken);

    } catch (_) {

      if (!mounted) return;



      final strings = AppLocalizations.of(context)!;



      ScaffoldMessenger.of(

        context,

      ).showSnackBar(SnackBar(content: Text(strings.loginGoogleError)));

    } finally {

      if (mounted) {

        setState(() => _isGoogleLoading = false);

      }

    }

  }







  void _goToForgotPassword() => context.push('/forgot-password');



  void _goToSignUp() => context.push('/signup');



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);



    final strings = AppLocalizations.of(context)!;



    final themeMode = ref.watch(themeModeProvider);



    final isDarkMode = themeMode == ThemeMode.dark;



    final layout = ResponsiveLayout.of(context);



    ref.listen<AuthState>(authProvider, (previous, next) {

      next.maybeWhen(

        authenticated: (_) {

          if (mounted) context.go('/home');

        },



        error: (message) {

          if (!mounted) return;



          ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(

              content: Text(message),



              behavior: SnackBarBehavior.floating,

            ),

          );

        },



        orElse: () {},

      );

    });



    final authState = ref.watch(authProvider);



    final isLoading = authState.maybeWhen(

      loading: () => true,



      orElse: () => false,

    );



    return Scaffold(

      body: Stack(

        children: [

          const _LoginAtmosphere(),



          SafeArea(

            child: Padding(

              padding: EdgeInsets.symmetric(

                horizontal: layout.horizontalPadding,



                vertical: layout.isCompact ? 12 : 24,

              ),



              child: LayoutBuilder(

                builder: (context, constraints) {

                  final isWide = constraints.maxWidth >= 960;



                  return Center(

                    child: ConstrainedBox(

                      constraints: BoxConstraints(

                        maxWidth: layout.maxContentWidth,

                      ),



                      child: Flex(

                        direction: isWide ? Axis.horizontal : Axis.vertical,



                        mainAxisAlignment: MainAxisAlignment.center,



                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.center,
                              child: _LoginCard(
                                strings: strings,
                                theme: theme,
                                isDarkMode: isDarkMode,
                                onToggleTheme: () => ref
                                    .read(themeModeProvider.notifier)
                                    .toggle(),
                                formKey: _formKey,
                                emailController: _email,
                                passwordController: _password,
                                obscurePassword: _obscurePassword,
                                onTogglePassword: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                isLoading: isLoading,
                                isGoogleLoading: _isGoogleLoading,
                                onCredentialsLogin: _handleCredentialsLogin,
                                onForgotPassword: _goToForgotPassword,
                                onSignUp: _goToSignUp,
                                onGoogleLogin: _handleGoogleLogin,

                                isCompact: layout.isCompact,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}





class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.strings,
    required this.theme,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.isLoading,
    required this.isGoogleLoading,
    required this.onCredentialsLogin,
    required this.onForgotPassword,
    required this.onSignUp,
    required this.onGoogleLogin,

    required this.isCompact,
  });

  final AppLocalizations strings;
  final ThemeData theme;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final bool isLoading;
  final bool isGoogleLoading;
  final VoidCallback onCredentialsLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onSignUp;
  final VoidCallback onGoogleLogin;

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppShadows.soft[0].color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 24 : 32),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Mascot and Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo Icon (Heart/Home)
                        SvgPicture.asset(
                          'assets/images/branding/logo.svg', // Assuming this is the heart/home icon
                          height: 40,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bienvenido a Mi Refugio',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu espacio seguro para cuidar tu bienestar emocional.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Brain Mascot
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: SvgPicture.asset(
                      'assets/images/mascot/Pose 1.svg', // Waving pose
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Email Input
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico', // Hardcoded to match screenshot for now, or use strings
                  // prefixIcon: const Icon(Icons.email_outlined), // Screenshot doesn't show icon inside? Or maybe it does.
                  // Screenshot shows clean rounded input. Let's keep it simple.
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.loginEmailEmptyError;
                  }
                  if (!value.contains('@')) {
                    return strings.loginEmailInvalidError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password Input
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  // prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return strings.loginPasswordEmptyError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onForgotPassword,
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Login Button
              FilledButton(
                onPressed: isLoading ? null : onCredentialsLogin,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7E57C2), // Purple from screenshot
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 16),
              
              // Guest Button
              /*
              OutlinedButton(
                onPressed: onGuestLogin,
                ...
              */

              // Google Login Button
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: isGoogleLoading ? null : onGoogleLogin,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isGoogleLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/iconos/google_logo.svg',
                            height: 24,
                            width: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Continuar con Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 32),

              // Create Account Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: onSignUp,
                    child: Text(
                      'Regístrate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.quote, required this.onGuideTap});

  final String quote;
  final VoidCallback onGuideTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFAFC9EF), Color(0xFFCAB9E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mi Refugio',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  child: Text(
                    quote,
                    key: ValueKey(quote),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onGuideTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.18),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Ver guía de acompañamiento'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 140,
              width: 110,
              color: Colors.white.withOpacity(0.12),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/mascot/pose3.svg',
                  height: 120,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginAtmosphere extends StatelessWidget {

  const _LoginAtmosphere();



  @override

  Widget build(BuildContext context) {

    return Stack(

      fit: StackFit.expand,

      children: [

        const DecoratedBox(

          decoration: BoxDecoration(

            gradient: LinearGradient(

              colors: [AppColors.background, AppColors.surfaceAlt],

              begin: Alignment.topCenter,

              end: Alignment.bottomCenter,

            ),

          ),

        ),

        Positioned(

          top: -60,

          right: -40,

          child: _blurCircle(AppColors.primary, 240),

        ),

        Positioned(

          bottom: -50,

          left: -60,

          child: _blurCircle(AppColors.secondary, 240),

        ),

      ],

    );

  }



  Widget _blurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.55),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 120,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }

}



class _SocialDivider extends StatelessWidget {
  const _SocialDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.black12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.black12)),
      ],
    );
  }
}





