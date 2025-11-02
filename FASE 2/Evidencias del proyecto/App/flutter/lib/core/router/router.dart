import "package:go_router/go_router.dart";
import "../../features/auth/presentation/pages/login_page.dart";
import "../../features/auth/presentation/pages/splash_page.dart";
import "../../features/bot/presentation/views/chat_view.dart";
import "../../features/diary/presentation/pages/diary_entry_form_page.dart";
import "../../features/diary/presentation/pages/diary_page.dart";
import "../../features/home/presentation/pages/home_page.dart";
import "../../features/navigation/presentation/widgets/main_shell.dart";
import "../../features/profile/presentation/pages/profile_page.dart";
import "../../features/resources/presentation/pages/resources_page.dart";
import "../../features/wellness/presentation/pages/hydration_page.dart";
import "../../features/wellness/presentation/pages/mindfulness_page.dart";
import "../../features/wellness/presentation/pages/nutrition_page.dart";

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'mindfulness',
                  builder: (context, state) => const MindfulnessPage(),
                ),
                GoRoute(
                  path: 'nutrition',
                  builder: (context, state) => const NutritionPage(),
                ),
                GoRoute(
                  path: 'hydration',
                  builder: (context, state) => const HydrationPage(),
                ),
                GoRoute(
                  path: 'resources',
                  builder: (context, state) => const ResourcesPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/diary',
              builder: (context, state) => const DiaryPage(),
              routes: [
                GoRoute(
                  path: 'entry/new',
                  builder: (context, state) => const DiaryEntryFormPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final location = state.uri.toString();
    final loggingIn = location == '/login';
    if (location == '/' || loggingIn) {
      return null;
    }
    // allow direct navigation to shell destinations
    return null;
  },
);
