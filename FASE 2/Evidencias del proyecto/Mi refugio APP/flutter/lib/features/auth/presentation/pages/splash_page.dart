import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth_provider.dart';
import '../../application/auth_state.dart';
import 'package:mi_refugio_app/shared/constants/app_colors.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Force logout to ensure clean state
    await ref.read(authProvider.notifier).logout();

    if (!mounted) return;

    // Directly go to login, bypassing auto-login check
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/images/branding/logo.svg',
            height: 80,
            width: 80,
            placeholderBuilder: (_) => const Icon(
              Icons.spa_rounded,
              size: 80,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
