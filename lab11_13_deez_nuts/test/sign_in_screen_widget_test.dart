import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lab11_13_deez_nuts/pages/sign_in_screen.dart';
import 'package:lab11_13_deez_nuts/services/firebase_service.dart';
import 'mocks.mocks.dart';

void main() {
  late MockFirebaseService mockFirebaseService;

  setUp(() {
    mockFirebaseService = MockFirebaseService();
  });

  testWidgets('SignInScreen allows email and password input', (
    WidgetTester tester,
  ) async {
    // Build the SignInScreen widget with a mock FirebaseService
    await tester.pumpWidget(
      MaterialApp(home: SignInScreen(firebaseService: mockFirebaseService)),
    );

    // Allow the widget to build completely
    await tester.pumpAndSettle();

    // Verify that the email field is present
    // Find by TextField properties instead of by type index
    final emailField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Email',
    );
    expect(emailField, findsOneWidget);

    // Enter text in the email field
    await tester.enterText(emailField, 'test@example.com');
    await tester.pump();

    // Verify that the password field is present
    final passwordField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Password',
    );
    expect(passwordField, findsOneWidget);

    // Enter text in the password field
    await tester.enterText(passwordField, 'password123');
    await tester.pump();

    // Verify the text was entered correctly
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });
}
