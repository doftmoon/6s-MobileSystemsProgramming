import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lab11_13_deez_nuts/pages/create_worker_dialog.dart';
import 'package:lab11_13_deez_nuts/services/firebase_service.dart';
import 'mocks.mocks.dart';

void main() {
  late MockFirebaseService mockFirebaseService;

  setUp(() {
    mockFirebaseService = MockFirebaseService();
  });

  testWidgets('CreateWorkerDialog allows filling out the form', (
    WidgetTester tester,
  ) async {
    // Build the CreateWorkerDialog widget with a mock FirebaseService
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => CreateWorkerDialog(
                            firebaseService: mockFirebaseService,
                          ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Verify the dialog is displayed
    expect(find.text('Create New Worker'), findsOneWidget);

    // Enter text in all fields
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Work Name'),
      'Test Work',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Test Worker',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Rate'), '100');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Discount (%)'),
      '10',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Payment per Hour'),
      '90',
    );
    await tester.pump();

    // Verify text was entered correctly
    expect(find.text('Test Work'), findsOneWidget);
    expect(find.text('Test Worker'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('90'), findsOneWidget);
  });
}
