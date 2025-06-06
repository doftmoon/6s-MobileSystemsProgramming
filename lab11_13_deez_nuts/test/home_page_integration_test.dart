import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lab11_13_deez_nuts/firebase_options.dart';
import 'package:lab11_13_deez_nuts/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('Home page test', (WidgetTester tester) async {
    await tester.pumpWidget(const App(firebaseInitialized: true));

    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
  });
}
