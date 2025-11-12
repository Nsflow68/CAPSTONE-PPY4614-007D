import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_refugio_app/main.dart';

void main() {
  testWidgets('App boots and renders without crashing', (tester) async {
    const size = Size(1080, 2400);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: MiRefugioApp()));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
