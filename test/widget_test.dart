import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:scout_display/main.dart';

void main() {
  testWidgets('HUD app smoke test', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.textContaining('MODE:'), findsOneWidget);
    expect(find.textContaining('UP TIME'), findsOneWidget);
  });
}
