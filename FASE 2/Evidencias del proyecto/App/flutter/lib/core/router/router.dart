// lib/core/router/router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_provider.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';

import '../../features/onboarding/presentation/pages/guide_page.dart';

import '../../features/navigation/presentation/widgets/main_shell.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/diary/presentation/pages/diary_page.dart';
import '../../features/diary/presentation/pages/diary_entry_form_page.dart';
import '../../features/chatbot/presentation/pages/chatbot_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/resources/presentation/pages/resources_page.dart';
import '../../features/rewards/presentation/pages/rewards_page.dart';
import '../../features/wellness/presentation/pages/hydration_page.dart';
import '../../features/wellness/presentation/pages/mindfulness_page.dart';
import '../../features/wellness/presentation/pages/nutrition_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    // Arranca en login; Splash sÃ³lo si lo navegas explÃ­citamente
    initialLocation: '/login',

    routes: [
      // PÃºblicas
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, __) => const SignUpPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(path: '/guide', builder: (_, __) => const GuidePage()),

      // Shell con bottom-navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, nav) => MainShell(navigationShell: nav),
        branches: [
          // INICIO
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'mindfulness',
                    builder: (_, __) => const MindfulnessPage(),
                  ),
                  GoRoute(
                    path: 'nutrition',
                    builder: (_, __) => const NutritionPage(),
                  ),
                  GoRoute(
                    path: 'hydration',
                    builder: (_, __) => const HydrationPage(),
                  ),
                  GoRoute(
                    path: 'resources',
                    builder: (_, __) => const ResourcesPage(),
                  ),
                  GoRoute(
                    path: 'rewards',
                    builder: (_, __) => const RewardsPage(),
                  ),
                  GoRoute(
                    path: 'chatbot',
                    builder: (_, __) => const ChatbotPage(),
                  ),
                ],
              ),
            ],
          ),
          // DIARIO
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
          // CHATBOT (tab directo)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chatbot',
                builder: (_, __) => const ChatbotPage(),
              ),
            ],
          ),
          // PERFIL
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

    // Guard de autenticaciÃ³n
    redirect: (context, state) async {
      final loc = state.uri.toString();
      const publicRoutes = [
        '/splash',
        '/login',
        '/signup',
        '/forgot-password',
        '/guide',
      ];

      if (publicRoutes.contains(loc)) return null;

      final isAuthenticated = await authRepository.isAuthenticated();
      return isAuthenticated ? null : '/login';
    },
  );
});
