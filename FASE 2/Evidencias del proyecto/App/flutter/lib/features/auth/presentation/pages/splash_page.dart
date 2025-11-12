import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final VideoPlayerController _videoController;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.asset(
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
        _goToLogin();
      }
    });
  }

  void _handleVideoState() {
    if (!mounted || _navigated) return;
    final value = _videoController.value;
    if (!value.isInitialized) return;
    final duration = value.duration;
    if (duration == Duration.zero) return;

    final position = value.position;
    if (position >= duration - const Duration(milliseconds: 150)) {
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (_navigated) return;
    _navigated = true;
    context.go('/login');
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
      backgroundColor: Colors.black,
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
                  colors: [Color(0xFF7C6CF8), Color(0xFFF1C6FF)],
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
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
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
