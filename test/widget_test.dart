// test/widget_test.dart
// Smoke test for CricTrack app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crictrack/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CricTrackApp()),
    );
    // App should render without throwing
    expect(find.byType(MaterialApp), findsNothing); // uses MaterialApp.router
    expect(tester.takeException(), isNull);
  });
}
