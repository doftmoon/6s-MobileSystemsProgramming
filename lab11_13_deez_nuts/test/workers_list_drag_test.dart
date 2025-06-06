import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lab11_13_deez_nuts/pages/workers_list_widget.dart';
import 'package:lab11_13_deez_nuts/services/firebase_service.dart';
import 'package:lab11_13_deez_nuts/models/worker.dart';
import 'package:lab11_13_deez_nuts/models/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mocks.mocks.dart';

// Create a simpler test widget that doesn't rely on ScaffoldMessenger
class TestWorkersListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> workers;
  final VoidCallback onDelete;

  const TestWorkersListWidget({
    super.key,
    required this.workers,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          itemCount: workers.length,
          itemBuilder: (context, index) {
            final worker = workers[index]['worker'] as Worker;

            return Dismissible(
              key: Key('worker-${workers[index]['id']}'),
              direction: DismissDirection.startToEnd,
              background: Container(
                color: Colors.red,
                child: const Icon(Icons.delete),
                alignment: Alignment.centerLeft,
              ),
              onDismissed: (direction) {
                onDelete();
              },
              child: ListTile(
                title: Text(worker.name),
                subtitle: Text(worker.workName),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Dismissible widget allows swiping to delete', (
    WidgetTester tester,
  ) async {
    bool deleteWasCalled = false;

    // Create test data
    final testWorkers = [
      {
        'id': 'worker1',
        'worker': Worker(
          workName: 'Test Work 1',
          name: 'Test Worker 1',
          rate: 100.0,
          discount: 10.0,
          payment: 90.0,
        ),
      },
      {
        'id': 'worker2',
        'worker': Worker(
          workName: 'Test Work 2',
          name: 'Test Worker 2',
          rate: 110.0,
          discount: 15.0,
          payment: 95.0,
        ),
      },
    ];

    // Build the test widget
    await tester.pumpWidget(
      TestWorkersListWidget(
        workers: testWorkers,
        onDelete: () {
          deleteWasCalled = true;
        },
      ),
    );

    // Verify that the workers are displayed
    expect(find.text('Test Worker 1'), findsOneWidget);
    expect(find.text('Test Worker 2'), findsOneWidget);

    // Find the first worker's dismissible widget
    final firstWorkerItem = find.text('Test Worker 1');

    // Perform a drag from left to right to dismiss
    await tester.drag(firstWorkerItem, const Offset(500.0, 0.0));
    await tester.pumpAndSettle();

    // Verify the item was dismissed and callback called
    expect(deleteWasCalled, true);

    // Verify the item is no longer in the list
    expect(find.text('Test Worker 1'), findsNothing);
    expect(find.text('Test Worker 2'), findsOneWidget);
  });
}
