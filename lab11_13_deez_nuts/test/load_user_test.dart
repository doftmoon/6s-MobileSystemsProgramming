// test/load_user_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab11_13_deez_nuts/models/user.dart';
import 'package:lab11_13_deez_nuts/services/firebase_service.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mocks.mocks.dart';
import 'package:flutter/foundation.dart'; // Still needed for debugPrint, but not for override in this test

// --- Копия вашего Home виджета для тестового файла (минимальная) ---
class Home extends StatefulWidget {
  final PageController pageController;
  final FirebaseService firebaseService;

  const Home({
    super.key,
    required this.pageController,
    required this.firebaseService,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadUser() async {
    try {
      final userId = _mockFirebaseAuthInstance?.currentUser?.uid;
      if (userId == null) return;

      final user = await widget.firebaseService.getUser(userId);
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      // Use debugPrint here, as it's what Flutter's print maps to in debug mode.
      // But we won't assert on its output in the test.
      debugPrint('Error loading user: $e');
    }
  }

  Future<void> _loadWorkers() async {}
  List<Widget> _buildCardList(List<Map<String, dynamic>> workerData) => [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Text(_currentUser?.name ?? 'No user loaded')),
    );
  }
}
// --- Конец копии Home виджета ---

MockFirebaseAuth? _mockFirebaseAuthInstance;

void main() {
  late MockFirebaseService mockFirebaseService;
  late MockUser mockFirebaseUser;
  late PageController pageController;

  setUp(() {
    mockFirebaseService = MockFirebaseService();
    mockFirebaseUser = MockUser();
    pageController = PageController();

    _mockFirebaseAuthInstance = MockFirebaseAuth();
  });

  tearDown(() {
    _mockFirebaseAuthInstance = null;
    reset(mockFirebaseService);
    reset(mockFirebaseUser);
    pageController.dispose();

    // No need to reset debugPrintOverride if we're not setting it for tests
  });

  group('_HomeState - _loadUser()', () {
    testWidgets(
      '_loadUser updates _currentUser state when user is successfully loaded',
      (WidgetTester tester) async {
        final testUserId = 'testUserId123';
        final testUserModel = UserModel(
          id: testUserId,
          name: 'Test User Name',
          role: UserRole.regular,
        );

        when(
          _mockFirebaseAuthInstance!.currentUser,
        ).thenReturn(mockFirebaseUser);
        when(mockFirebaseUser.uid).thenReturn(testUserId);

        when(
          mockFirebaseService.getUser(testUserId),
        ).thenAnswer((_) async => testUserModel);

        await tester.pumpWidget(
          Home(
            pageController: pageController,
            firebaseService: mockFirebaseService,
          ),
        );

        final _HomeState state = tester.state(find.byType(Home));

        await state._loadUser();

        await tester.pump();

        expect(state._currentUser, testUserModel);
        expect(find.text('Test User Name'), findsOneWidget);

        verify(_mockFirebaseAuthInstance!.currentUser).called(1);
        verify(mockFirebaseUser.uid).called(1);
        verify(mockFirebaseService.getUser(testUserId)).called(1);
        verifyNoMoreInteractions(mockFirebaseService);
      },
    );

    testWidgets('_loadUser does nothing if FirebaseAuth.currentUser is null', (
      WidgetTester tester,
    ) async {
      when(_mockFirebaseAuthInstance!.currentUser).thenReturn(null);

      await tester.pumpWidget(
        Home(
          pageController: pageController,
          firebaseService: mockFirebaseService,
        ),
      );

      final _HomeState state = tester.state(find.byType(Home));

      await state._loadUser();

      expect(state._currentUser, isNull);
      expect(find.text('No user loaded'), findsOneWidget);

      verify(_mockFirebaseAuthInstance!.currentUser).called(1);
      verifyNever(mockFirebaseService.getUser(any));
    });

    testWidgets('_loadUser handles errors during user loading', (
      WidgetTester tester,
    ) async {
      final testUserId = 'testUserId123';

      when(_mockFirebaseAuthInstance!.currentUser).thenReturn(mockFirebaseUser);
      when(mockFirebaseUser.uid).thenReturn(testUserId);

      when(
        mockFirebaseService.getUser(testUserId),
      ).thenThrow(Exception('Failed to load user'));

      await tester.pumpWidget(
        Home(
          pageController: pageController,
          firebaseService: mockFirebaseService,
        ),
      );

      final _HomeState state = tester.state(find.byType(Home));

      // No need to capture logs for this test's assertion.
      // The observable effect is that _currentUser remains null.

      await state._loadUser();
      await tester
          .pump(); // Pump to allow setState to complete, though _currentUser will be null

      // Assert that _currentUser is still null (it wasn't updated)
      expect(state._currentUser, isNull);
      expect(find.text('No user loaded'), findsOneWidget);

      // Verify that getUser was indeed called and threw an error
      verify(_mockFirebaseAuthInstance!.currentUser).called(1);
      verify(mockFirebaseUser.uid).called(1);
      verify(mockFirebaseService.getUser(testUserId)).called(1);
      verifyNoMoreInteractions(mockFirebaseService);
    });
  });
}
