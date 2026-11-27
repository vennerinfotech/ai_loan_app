import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// Simple and lightweight session manager using SharedPreferences.
/// Uses [setString] and [getString] to store and check user authentication state.
class SessionManager {
  static const String keyIsLogin = 'is_login';
  static const String keyUserPhone = 'user_phone';
  static const String keyUserName = 'user_name';
  static const String keyUserId = 'user_id';
  static const String keyAuthToken = 'auth_token';
  static const String keyCurrentStep = 'current_step';

  /// Save login session into SharedPreferences using setString
  static Future<void> saveLoginSession({
    String? phone,
    String? name,
    String? token,
    dynamic userId,
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
    if (userId != null && userId.toString().trim().isNotEmpty) {
      await prefs.setString(keyUserId, userId.toString().trim());
    }
    // Sync FCM device token with backend now that user is logged in
    try {
      NotificationService.instance.syncDeviceToken();
    } catch (_) {}
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
    return prefs.getString(keyUserName) ?? '';
  }

  /// Get saved user ID
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserId) ?? '';
  }

  /// Save user ID
  static Future<void> saveUserId(dynamic userId) async {
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserId, userId.toString().trim());
  }

  /// Clear login session completely
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLogin);
    await prefs.remove(keyUserPhone);
    await prefs.remove(keyUserName);
    await prefs.remove(keyUserId);
    await prefs.remove(keyAuthToken);
    await prefs.remove(keyCurrentStep);
    await prefs.clear();
  }

  /// Save current onboarding step
  static Future<void> saveCurrentStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyCurrentStep, step);
  }

  /// Get current onboarding step
  static Future<int> getCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyCurrentStep) ?? 0;
  }
}
