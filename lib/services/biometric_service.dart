import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Service managing device biometric authentication and hardware-backed MPIN storage.
/// Biometric login is always available when device supports it AND a stored MPIN exists.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  static const String _keySecureMpinPrefix = 'secure_user_mpin';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Normalizes phone number so '+91 9876543210' and '9876543210' share the same key.
  String _storageKeyForPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return _keySecureMpinPrefix;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return _keySecureMpinPrefix;
    final normalized =
        digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    return '${_keySecureMpinPrefix}_$normalized';
  }

  /// Checks if device has biometric hardware and enrolled fingerprints/face
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      if (!canCheck && !isSupported) return false;

      final List<BiometricType> available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty || canCheck;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    } catch (e) {
      debugPrint('Unexpected error in isBiometricAvailable: $e');
      return false;
    }
  }

  /// Prompts user to authenticate with fingerprint/biometric
  Future<bool> authenticate({
    String localizedReason = 'Scan your fingerprint to log in to Finsphere',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      debugPrint('PlatformException in authenticate: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error in authenticate: $e');
      return false;
    }
  }

  /// Checks if biometric login is ready: device supports biometrics + stored MPIN exists
  Future<bool> isBiometricReady({String? phone}) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) return false;

      final mpin = await getStoredMpin(phone: phone);
      return mpin != null && mpin.trim().length == 6;
    } catch (e) {
      debugPrint('Error in isBiometricReady: $e');
      return false;
    }
  }

  /// Saves the 6-digit MPIN into Android Keystore / iOS Keychain
  Future<void> saveStoredMpin(String mpin, {String? phone}) async {
    try {
      if (mpin.trim().length == 6) {
        await _secureStorage.write(
          key: _storageKeyForPhone(phone),
          value: mpin.trim(),
        );
      }
    } catch (e) {
      debugPrint('Error saving stored MPIN: $e');
    }
  }

  /// Retrieves the 6-digit MPIN from Android Keystore / iOS Keychain
  Future<String?> getStoredMpin({String? phone}) async {
    try {
      return await _secureStorage.read(key: _storageKeyForPhone(phone));
    } catch (e) {
      debugPrint('Error reading stored MPIN: $e');
      return null;
    }
  }

  /// Deletes stored MPIN from secure storage
  Future<void> deleteStoredMpin({String? phone}) async {
    try {
      await _secureStorage.delete(key: _storageKeyForPhone(phone));
    } catch (e) {
      debugPrint('Error deleting stored MPIN: $e');
    }
  }
}
