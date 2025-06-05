import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lab11_13_deez_nuts/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPreferences {
  static const String _userKey = 'user_data';
  static const String _authUserKey = 'auth_user_data';
  static const String _lastLoginTimeKey = 'last_login_time';

  // Save user model to SharedPreferences
  static Future<bool> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode(user.toJson());
    return await prefs.setString(_userKey, userData);
  }

  // Get user model from SharedPreferences
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);

    if (userData == null) {
      return null;
    }

    try {
      final userMap = json.decode(userData) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  // Save auth user data to SharedPreferences
  static Future<bool> saveAuthUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
    };

    // Also save the current timestamp
    await prefs.setInt(
      _lastLoginTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );

    return await prefs.setString(_authUserKey, json.encode(userData));
  }

  // Get auth user data from SharedPreferences
  static Future<Map<String, dynamic>?> getAuthUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_authUserKey);

    if (userData == null) {
      return null;
    }

    try {
      return json.decode(userData) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing auth user data: $e');
      return null;
    }
  }

  // Check if login is still valid (not older than 30 days)
  static Future<bool> isLoginValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginTime = prefs.getInt(_lastLoginTimeKey);

    if (lastLoginTime == null) {
      return false;
    }

    final lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginTime);
    final now = DateTime.now();

    // Consider login valid for 30 days
    return now.difference(lastLogin).inDays < 30;
  }

  // Clear all user data
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_authUserKey);
    await prefs.remove(_lastLoginTimeKey);
  }
}
