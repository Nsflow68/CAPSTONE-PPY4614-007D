import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../application/auth_provider.dart';
import '../../application/auth_state.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';

/// Pantalla de splash que muestra un video de carga y verifica
/// el estado de autenticación para decidir el flujo inicial.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  late final VideoPlayerController _videoController;
  bool _navigated = false;
  bool _authChecked = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/videos/pantalla_carga.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _videoController.play();
      });
    _videoController.setLooping(false);
    _videoController.addListener(_handleVideoState);

    // Failsafe por si el video no se reproduce
    Timer(const Duration(seconds: 6), () {
      if (!_navigated && mounted) {
        _navigateToNextScreen();
      }
    });

    // Verificar estado de autenticación de inmediato
    _checkAuthenticationStatus();
  }

  /// Verifica el estado de autenticación usando el repository
  /// para determinar si hay una sesión válida.
  Future<void> _checkAuthenticationStatus() async {
    if (_authChecked) return;
    _authChecked = true;

    // Dar un pequeño delay para que el video comience a reproducirse
    await Future.delayed(const Duration(milliseconds: 500));

    final repository = ref.read(authRepositoryProvider);
    final isAuthenticated = await repository.isAuthenticated();

    // Si hay sesión válida, simplemente continuamos al siguiente flujo (router guard).
    if (isAuthenticated && mounted) {
      await repository.getCurrentUser();
    }
  }

  void _handleVideoState() {
    if (!mounted || _navigated) return;
    final value = _videoController.value;
    if (!value.isInitialized) return;
    final duration = value.duration;
    if (duration == Duration.zero) return;

    final position = value.position;
    if (position >= duration - const Duration(milliseconds: 150)) {
      _navigateToNextScreen();
    }
  }

  /// Navega a /home si está autenticado, o a /login si no lo está.
  /// El router guard se encargará de redirigir correctamente.
  void _navigateToNextScreen() {
    if (_navigated) return;
    _navigated = true;

    final authState = ref.read(authProvider);
    final isAuthenticated = authState is AuthAuthenticated;

    // Navegar según estado de autenticación
    if (isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_handleVideoState);
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoController.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.48),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            left: 32,
            right: 32,
            bottom: 64,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutExpo,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: child,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Mi Refugio',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Un espacio sensorial que te acompaña en cada emoción. '
                    'Respira, escucha y déjate guiar.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
