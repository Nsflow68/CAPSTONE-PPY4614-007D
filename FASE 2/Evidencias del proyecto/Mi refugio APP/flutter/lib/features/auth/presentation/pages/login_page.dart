import 'dart:async';



import 'package:flutter/material.dart';



import 'package:flutter_riverpod/flutter_riverpod.dart';



import 'package:flutter_svg/flutter_svg.dart';



import 'package:go_router/go_router.dart';



import 'package:google_sign_in/google_sign_in.dart';



import 'package:mi_refugio_app/core/services/theme_controller.dart';



import 'package:mi_refugio_app/l10n/app_localizations.dart';



import 'package:mi_refugio_app/shared/constants/app_colors.dart';



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



  Future<void> _handleGuest() async {

    if (_isGoogleLoading) return;



    await ref.read(authProvider.notifier).loginAsGuest();

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

                            flex: isWide ? 3 : 0,



                            child: _HeroPanel(

                              quote: _quotes[_quoteIndex],



                              onGuideTap: () => context.go('/guide'),

                            ),

                          ),



                          SizedBox(

                            width: isWide ? 40 : 0,



                            height: isWide ? 0 : 32,

                          ),



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



                                onGuestLogin: _handleGuest,



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

    required this.onGuestLogin,

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

  final VoidCallback onGuestLogin;

  final bool isCompact;



  bool get _isBusy => isLoading || isGoogleLoading;

  @override

  Widget build(BuildContext context) {

    InputDecoration decoration({

      required String label,

      String? hint,

      IconData? icon,

      Widget? suffixIcon,

    }) {

      return InputDecoration(

        labelText: label,

        hintText: hint,

        prefixIcon: icon != null ? Icon(icon) : null,

        suffixIcon: suffixIcon,

      );

    }



    final cardPadding = EdgeInsets.all(isCompact ? 20 : 28);

    final titleSpacing = isCompact ? 12.0 : 20.0;



    return TweenAnimationBuilder<double>(

      tween: Tween(begin: 0.97, end: 1),

      duration: const Duration(milliseconds: 420),

      curve: Curves.easeOutBack,

      builder: (context, scale, child) =>

          Transform.scale(scale: scale, child: child),

      child: AnimatedContainer(

        duration: const Duration(milliseconds: 450),

        curve: Curves.easeOutCubic,

        padding: cardPadding,

        decoration: BoxDecoration(

          color: theme.colorScheme.surface,

          borderRadius: BorderRadius.circular(30),

          boxShadow: AppShadows.soft,

        ),

        child: LayoutBuilder(

          builder: (context, constraints) {

            return SingleChildScrollView(

              padding: EdgeInsets.zero,

              child: ConstrainedBox(

                constraints: BoxConstraints(minWidth: constraints.maxWidth),

                child: Form(

                  key: formKey,

                  child: Column(

                    mainAxisSize: MainAxisSize.min,

                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [

                      Center(

                        child: Container(

                          height: 120,

                          width: 120,

                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(

                            shape: BoxShape.circle,

                            gradient: const LinearGradient(

                              colors: [AppColors.primary, AppColors.tertiary],

                              begin: Alignment.topLeft,

                              end: Alignment.bottomRight,

                            ),

                            boxShadow: AppShadows.soft,

                          ),

                          child: SvgPicture.asset(

                            'assets/images/mascot/pose2b.svg',

                            fit: BoxFit.contain,

                          ),

                        ),

                      ),

                      SizedBox(height: titleSpacing),

                      Text(

                        strings.loginWelcomeTitle,

                        textAlign: TextAlign.center,

                        style: theme.textTheme.headlineMedium?.copyWith(

                          fontWeight: FontWeight.w800,

                          color: theme.colorScheme.onSurface,

                          letterSpacing: -0.3,

                        ),

                      ),

                      SizedBox(height: isCompact ? 6 : 10),

                      Text(

                        strings.loginWelcomeSubtitle,

                        textAlign: TextAlign.center,

                        style: theme.textTheme.bodyLarge?.copyWith(

                          color: AppColors.textSecondary,

                          height: 1.45,

                        ),

                      ),

                      const SizedBox(height: 24),

                      TextFormField(

                        controller: emailController,

                        keyboardType: TextInputType.emailAddress,

                        textInputAction: TextInputAction.next,

                        decoration: decoration(

                          label: strings.loginEmailLabel,

                          hint: strings.loginEmailHint,

                          icon: Icons.mail_outline_rounded,

                        ),

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

                      const SizedBox(height: 14),

                      TextFormField(

                        controller: passwordController,

                        obscureText: obscurePassword,

                        textInputAction: TextInputAction.done,

                        onFieldSubmitted: (_) => onCredentialsLogin(),

                        decoration: decoration(

                          label: strings.loginPasswordLabel,

                          icon: Icons.lock_outline_rounded,

                          suffixIcon: IconButton(

                            icon: Icon(

                              obscurePassword

                                  ? Icons.visibility_outlined

                                  : Icons.visibility_off_outlined,

                            ),

                            onPressed: onTogglePassword,

                          ),

                        ),

                        validator: (value) {

                          if (value == null || value.isEmpty) {

                            return strings.loginPasswordEmptyError;

                          }

                          return null;

                        },

                      ),

                      const SizedBox(height: 6),

                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 6,
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: _isBusy ? null : onForgotPassword,
                            child: Text(strings.loginForgotPassword),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.dark_mode_rounded,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Switch(
                                value: isDarkMode,
                                onChanged: (_) => onToggleTheme(),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      SizedBox(

                        height: 54,

                        child: FilledButton(

                          onPressed: _isBusy ? null : onCredentialsLogin,

                          style: FilledButton.styleFrom(

                            backgroundColor: AppColors.tertiary,

                            foregroundColor: Colors.white,

                            shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(16),

                            ),

                          ),

                          child: isLoading

                              ? const SizedBox(

                                  width: 20,

                                  height: 20,

                                  child: CircularProgressIndicator(

                                    strokeWidth: 2.4,

                                    color: Colors.white,

                                  ),

                                )

                              : Text(

                                  strings.loginPrimaryButton,

                                  style: theme.textTheme.titleMedium

                                      ?.copyWith(color: Colors.white),

                                ),

                        ),

                      ),

                      const SizedBox(height: 14),

                      _SocialDivider(label: strings.loginSocialDivider),

                      const SizedBox(height: 14),

                      OutlinedButton.icon(

                        onPressed: _isBusy ? null : onGoogleLogin,

                        icon: isGoogleLoading

                            ? const SizedBox(

                                width: 20,

                                height: 20,

                                child: CircularProgressIndicator(

                                  strokeWidth: 2.3,

                                ),

                              )

                            : SvgPicture.asset(

                                'assets/icons/google_logo.svg',

                                width: 20,

                                height: 20,

                                semanticsLabel: 'Google',

                              ),

                        label: Text(strings.loginGoogleButton),

                        style: OutlinedButton.styleFrom(

                          minimumSize: const Size.fromHeight(52),

                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(16),

                          ),

                        ),

                      ),

                      const SizedBox(height: 12),

                      OutlinedButton.icon(

                        onPressed: _isBusy ? null : onGuestLogin,

                        icon: const Icon(Icons.shield_moon_outlined),

                        style: OutlinedButton.styleFrom(

                          minimumSize: const Size.fromHeight(52),

                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(16),

                          ),

                        ),

                        label: Text(strings.loginContinueGuest),

                      ),

                      const SizedBox(height: 16),

                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            strings.loginNoAccountQuestion,
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: _isBusy ? null : onSignUp,
                            child: Text(strings.loginRegisterAction),
                          ),
                        ],
                      ),
                    ],

                  ),

                ),

              ),

            );

          },

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
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onGuideTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
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
              color: Colors.white.withValues(alpha: 0.12),
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



        color: color.withValues(alpha: 0.55),



        boxShadow: [

          BoxShadow(

            color: color.withValues(alpha: 0.4),



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

        Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.08))),



        Padding(

          padding: const EdgeInsets.symmetric(horizontal: 12),



          child: Text(

            label,



            style: theme.textTheme.bodyMedium?.copyWith(

              color: AppColors.textSecondary.withValues(alpha: 0.8),

            ),

          ),

        ),



        Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.08))),

      ],

    );

  }

}





