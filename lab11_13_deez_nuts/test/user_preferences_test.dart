import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab11_13_deez_nuts/models/user.dart';
import 'package:lab11_13_deez_nuts/services/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UserPreferences', () {
    setUpAll(() {
      SharedPreferences.setMockInitialValues(
        {},
      ); // Инициализируем SharedPreferences для тестов
    });

    setUp(() {
      SharedPreferences.setMockInitialValues(
        {},
      ); // Очищаем данные перед каждым тестом
    });

    test('getUser returns null if no user data is stored', () async {
      final user = await UserPreferences.getUser();
      expect(user, isNull);
    });

    test('getUser returns UserModel if data is stored', () async {
      final testUser = UserModel(
        id: 'test_uid_123',
        name: 'Test User',
        role: UserRole.admin,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(testUser.toJson()));

      final retrievedUser = await UserPreferences.getUser();

      expect(retrievedUser, isA<UserModel>());
      expect(retrievedUser!.id, testUser.id);
    });
  });
}
