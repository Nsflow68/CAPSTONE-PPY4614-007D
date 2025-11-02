import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:video_player/video_player.dart";

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initialize();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go("/login");
    });
  }

  Future<void> _initialize() async {
    final controller = VideoPlayerController.asset(
      "assets/videos/pantalla_carga.mp4",
    );
    try {
      await controller.initialize();
      controller
        ..setLooping(true)
        ..setVolume(0)
        ..play();
      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    } catch (_) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7E6BC4), Color(0xFFF8C8DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          gradient,
          if (_controller != null && _controller!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          Container(color: Colors.black.withValues(alpha: 0.25)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/branding/logo_primary.png",
                  height: 120,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Tu espacio seguro para cuidar tu bienestar emocional.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

