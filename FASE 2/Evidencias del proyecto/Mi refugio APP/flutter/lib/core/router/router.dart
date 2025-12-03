// lib/core/router/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_provider.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';

// import '../../features/onboarding/presentation/pages/guide_page.dart';

import '../../features/navigation/presentation/widgets/main_shell.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/diary/presentation/pages/diary_page.dart';
import '../../features/diary/presentation/pages/diary_entry_form_page.dart';
import '../../features/chatbot/presentation/pages/chatbot_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/rewards/presentation/pages/rewards_page.dart';
import '../../features/wellness/presentation/pages/hydration_page.dart';
import '../../features/wellness/presentation/pages/mindfulness_page.dart';
import '../../features/wellness/presentation/pages/nutrition_page.dart';
import '../../features/wellness/presentation/pages/wellness_page.dart';

/// Provider del router principal de la aplicación.
///
/// Utiliza GoRouter con un guard de autenticación que escucha el estado
/// de Auth para proteger rutas privadas y gestionar el flujo de navegación.
final appRouterProvider = Provider<GoRouter>((ref) {
  // DO NOT watch authProvider here, it causes GoRouter to be recreated on every auth change!
  // final authState = ref.watch(authProvider);

  return GoRouter(
    // Arranca en splash para decidir el flujo inicial
    initialLocation: '/splash',

    // Refresh listener: hace que el router reaccione a cambios en authState
    refreshListenable: _AuthChangeNotifier(ref),

    routes: [
      // ═══════════════════════════════════════════════════════════════
      // RUTAS PÚBLICAS
      // ═══════════════════════════════════════════════════════════════

      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashPage(),
      ),

      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),

      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignUpPage(),
      ),

      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),

      // Guide route removed as requested

      // ═══════════════════════════════════════════════════════════════
      // RUTAS PRIVADAS (Shell con bottom navigation)
      // ═══════════════════════════════════════════════════════════════

      StatefulShellRoute.indexedStack(
        builder: (context, state, nav) => MainShell(navigationShell: nav),
        branches: [
          // 1. INICIO
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'chatbot',
                    builder: (_, __) => const ChatbotPage(),
                  ),
                ],
              ),
            ],
          ),

          // 2. DIARIO
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diary',
                builder: (_, __) => const DiaryPage(),
                routes: [
                  GoRoute(
                    path: 'entry/new',
                    builder: (_, __) => const DiaryEntryFormPage(),
                  ),
                ],
              ),
            ],
          ),

          // 3. BIENESTAR (Wellness)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wellness',
                builder: (_, __) => const WellnessPage(),
                routes: [
                  GoRoute(
                    path: 'nutrition',
                    builder: (_, __) => const NutritionPage(),
                  ),
                  GoRoute(
                    path: 'hydration',
                    builder: (_, __) => const HydrationPage(),
                  ),
                  GoRoute(
                    path: 'mindfulness',
                    builder: (_, __) => const MindfulnessPage(),
                  ),
                ],
              ),
            ],
          ),

          // 4. RECOMPENSAS (Progreso)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rewards',
                builder: (_, __) => const RewardsPage(),
              ),
            ],
          ),

          // 5. PERFIL
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],

    // ═══════════════════════════════════════════════════════════════
    // GUARD DE AUTENTICACIÓN
    // ═══════════════════════════════════════════════════════════════
    redirect: (context, state) {
      final location = state.uri.toString();

      // Lista de rutas públicas que no requieren autenticación
      const publicRoutes = {
        '/splash',
        '/login',
        '/signup',
        '/forgot-password',
      };

      // Determinar si el usuario está autenticado basado en AuthState ACTUAL
      final authState = ref.read(authProvider);
      final isAuthenticated = authState is AuthAuthenticated;
      
      print('ROUTER DEBUG: Location: $location, Auth: $isAuthenticated');

      // Si estamos en splash, dejar pasar (Splash decidirá el flujo)
      if (location == '/splash') {
        return null;
      }

      // Si el usuario NO está autenticado
      if (!isAuthenticated) {
        // Si intenta acceder a una ruta privada, redirigir a login
        if (!publicRoutes.contains(location)) {
          print('ROUTER DEBUG: Redirecting to /login (Not authenticated)');
          return '/login';
        }
        // Si está en una ruta pública, permitir acceso
        return null;
      }

      // Si el usuario SÍ está autenticado
      if (isAuthenticated) {
        // Si intenta acceder a login o signup, redirigir a home
        // (evita que usuario autenticado vuelva a login con back button)
        if (location == '/login' || location == '/signup') {
           print('ROUTER DEBUG: Authenticated, redirecting to /home');
           return '/home';
        }
        // Para otras rutas (públicas o privadas), permitir acceso
        return null;
      }

      return null;
    },
  );
});

/// Notifier personalizado para hacer que GoRouter reaccione a cambios en AuthState.
///
/// GoRouter escucha este ChangeNotifier y vuelve a evaluar el redirect
/// cada vez que el estado de autenticación cambia.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    // Escuchar cambios en authProvider
    _ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        // Notificar a GoRouter que el estado cambió para re-evaluar redirect
        notifyListeners();
      },
    );
  }

  final Ref _ref;
}
