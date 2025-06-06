import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lab11_13_deez_nuts/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches and is on sign in screen', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final signUpScreenFinder = find.byKey(const Key('SignIn'));
    const timeout = Duration(seconds: 30);
    bool found = false;
    final startTime = DateTime.now();
    while (!found && DateTime.now().difference(startTime) < timeout) {
      await tester.pump();
      found = tester.any(signUpScreenFinder);
    }

    expect(signUpScreenFinder, findsOneWidget);
  });
}
