import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lab11_13_deez_nuts/pages/create_worker_dialog.dart';
import 'package:lab11_13_deez_nuts/services/firebase_service.dart';
import 'package:lab11_13_deez_nuts/models/worker.dart';
import 'mocks.mocks.dart';

void main() {
  late MockFirebaseService mockFirebaseService;

  setUp(() {
    mockFirebaseService = MockFirebaseService();
    when(
      mockFirebaseService.createWorker(any),
    ).thenAnswer((_) => Future.value());
  });

  testWidgets('CreateWorkerDialog save button calls createWorker', (
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

    // Fill in the form
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

    // Find and tap the save button
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify that createWorker was called with the correct data
    verify(mockFirebaseService.createWorker(any)).called(1);
  });

  testWidgets('CreateWorkerDialog cancel button closes dialog without saving', (
    WidgetTester tester,
  ) async {
    // Build the dialog
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

    // Show the dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog is shown
    expect(find.text('Create New Worker'), findsOneWidget);

    // Tap the cancel button
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // Verify dialog is closed
    expect(find.text('Create New Worker'), findsNothing);

    // Verify that createWorker was not called
    verifyNever(mockFirebaseService.createWorker(any));
  });
}
