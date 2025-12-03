import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_refugio_app/features/home/presentation/pages/home_page.dart';
import 'package:mi_refugio_app/features/wellness/presentation/pages/wellness_page.dart';
import 'package:mi_refugio_app/features/rewards/presentation/pages/rewards_page.dart';

void main() {
  // Helper to pump a widget with ProviderScope and Material scaffolding
  Future<void> pumpScreen(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('HomePage builds correctly', (tester) async {
    await pumpScreen(tester, const HomePage());
    expect(find.textContaining('Hola,'), findsOneWidget);
    expect(find.text('¿Cómo te sientes hoy?'), findsOneWidget);
  });

  testWidgets('WellnessPage builds correctly', (tester) async {
    await pumpScreen(tester, const WellnessPage());
    expect(find.text('Bienestar'), findsOneWidget);
    expect(find.text('Hidratación'), findsOneWidget);
    expect(find.text('Nutrición'), findsOneWidget);
  });

  testWidgets('RewardsPage builds correctly', (tester) async {
    await pumpScreen(tester, const RewardsPage());
    expect(find.text('Recompensas'), findsOneWidget);
    // Note: Points might be 0 or loading, but the title should be there
  });
}
