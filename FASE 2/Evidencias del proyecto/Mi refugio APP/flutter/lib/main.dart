import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_refugio_app/core/router/router.dart';
import 'package:mi_refugio_app/core/services/api_service.dart';
import 'package:mi_refugio_app/core/services/storage_service.dart';
import 'package:mi_refugio_app/core/services/notification_service.dart';
import 'package:mi_refugio_app/core/services/theme_controller.dart';
import 'package:mi_refugio_app/core/theme/app_theme.dart';
import 'package:mi_refugio_app/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.initialize();
  await NotificationService().initialize();
  ApiService.instance.initialize(storage: StorageService.instance);
  runApp(const ProviderScope(child: MiRefugioApp()));
}

class MiRefugioApp extends ConsumerWidget {
  const MiRefugioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Mi Refugio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
