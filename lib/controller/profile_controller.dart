import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../screens/login_with_mobile_screen.dart';
import '../theme/app_colors.dart';

/// Controller managing user profile data, avatar image, and updates
class ProfileController extends GetxController {
  final firstName = 'Aarav'.obs;
  final lastName = 'Mehta'.obs;
  final email = 'aarav@example.com'.obs;
  final phone = '+91 98765 43210'.obs;
  final address = '123, MG Road, Bengaluru 560001'.obs;
  final isLoggingOut = false.obs;

  // Saved profile image
  final profileImageBytes = Rxn<Uint8List>();
  final profileImagePath = ''.obs;

  // Staged profile image during editing in Edit Profile screen
  final tempImageBytes = Rxn<Uint8List>();
  final tempImagePath = ''.obs;

  // Selected language preference
  final selectedLanguage = 'English'.obs;

  void setLanguage(String lang) {
    selectedLanguage.value = lang;
  }

  String get fullName => '${firstName.value} ${lastName.value}'.trim();

  String get initials {
    final f = firstName.value.isNotEmpty ? firstName.value[0].toUpperCase() : '';
    final l = lastName.value.isNotEmpty ? lastName.value[0].toUpperCase() : '';
    return '$f$l'.isEmpty ? 'AM' : '$f$l';
  }

  void setTempImage(Uint8List bytes, String path) {
    tempImageBytes.value = bytes;
    tempImagePath.value = path;
  }

  void saveProfile({
    required String first,
    required String last,
    required String emailAddress,
    required String addr,
  }) {
    if (first.isNotEmpty) firstName.value = first;
    if (last.isNotEmpty) lastName.value = last;
    if (emailAddress.isNotEmpty) email.value = emailAddress;
    if (addr.isNotEmpty) address.value = addr;

    if (tempImageBytes.value != null) {
      profileImageBytes.value = tempImageBytes.value;
      profileImagePath.value = tempImagePath.value;
      tempImageBytes.value = null;
      tempImagePath.value = '';
    }
  }

  void clearTempImage() {
    tempImageBytes.value = null;
    tempImagePath.value = '';
  }

  /// Logout user: calls POST /logout, clears session, and navigates to login
  Future<void> logout() async {
    isLoggingOut.value = true;
    try {
      final token = await SessionManager.getAuthToken();

      // Smooth UX delay + API call
      final results = await Future.wait([
        ApiService.logout(token: token),
        Future.delayed(const Duration(milliseconds: 700)),
      ]);

      final response = results[0] as Map<String, dynamic>;

      // Dismiss dialog if still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      isLoggingOut.value = false;

      // Always clear local session
      await SessionManager.clearSession();

      final message =
          response['message']?.toString() ?? 'Logged out successfully.';
      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );

      Get.offAll(() => const LoginWithMobileScreen());
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      isLoggingOut.value = false;
      await SessionManager.clearSession();
      Get.offAll(() => const LoginWithMobileScreen());
    }
  }
}
