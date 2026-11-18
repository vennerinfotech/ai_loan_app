import 'package:shared_preferences/shared_preferences.dart';

/// Simple and lightweight session manager using SharedPreferences.
/// Uses [setString] and [getString] to store and check user authentication state.
class SessionManager {
  static const String keyIsLogin = 'is_login';
  static const String keyUserPhone = 'user_phone';
  static const String keyUserName = 'user_name';
  static const String keyAuthToken = 'auth_token';

  /// Save login session into SharedPreferences using setString
  static Future<void> saveLoginSession({
    String? phone,
    String? name,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyIsLogin, 'true');
    if (phone != null && phone.trim().isNotEmpty) {
      await prefs.setString(keyUserPhone, phone.trim());
    }
    if (name != null && name.trim().isNotEmpty) {
      await prefs.setString(keyUserName, name.trim());
    }
    if (token != null && token.trim().isNotEmpty) {
      await prefs.setString(keyAuthToken, token.trim());
    }
  }

  /// Get saved auth token
  static Future<String> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyAuthToken) ?? '';
  }

  /// Check whether user is already logged in using getString
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogin = prefs.getString(keyIsLogin);
    return isLogin == 'true';
  }

  /// Get saved phone number using getString
  static Future<String> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserPhone) ?? '';
  }

  /// Get saved user name using getString
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName) ?? 'Aarav Mehta';
  }

  /// Clear login session using setString (or remove)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyIsLogin, 'false');
  }
}
