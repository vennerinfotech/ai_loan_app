import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../theme/app_colors.dart';

/// Controller managing user profile data, avatar image, and updates
class ProfileController extends GetxController {
  // Profile fields matching update profile API body:
  // { name, email, dob, gender, marital_status, address, address_type }
  final name = 'Rahul Sharma'.obs;
  final firstName = 'Rahul'.obs;
  final lastName = 'Sharma'.obs;
  final email = 'rahul.sharma@example.com'.obs;
  final phone = '+91 98765 43210'.obs;
  final dob = '1992-03-20'.obs;
  final gender = 'Male'.obs;
  final maritalStatus = 'Married'.obs;
  final address = 'Flat 402, Sunshine Heights, Surat'.obs;
  final addressType = 'Owned'.obs;
  final isLoggingOut = false.obs;

  // Saved profile image
  final profileImageBytes = Rxn<Uint8List>();
  final profileImagePath = ''.obs;

  // Staged profile image during editing
  final tempImageBytes = Rxn<Uint8List>();
  final tempImagePath = ''.obs;

  // Selected language preference
  final selectedLanguage = 'English'.obs;

  void setLanguage(String lang) {
    selectedLanguage.value = lang;
  }

  String get fullName => name.value.isNotEmpty ? name.value : '${firstName.value} ${lastName.value}'.trim();

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'RS';
  }

  void setTempImage(Uint8List bytes, String path) {
    tempImageBytes.value = bytes;
    tempImagePath.value = path;
  }

  void saveProfile({
    String? fullName,
    String? first,
    String? last,
    String? emailAddress,
    String? dateOfBirth,
    String? userGender,
    String? userMaritalStatus,
    String? addr,
    String? addrType,
  }) {
    if (fullName != null && fullName.isNotEmpty) {
      name.value = fullName;
      final parts = fullName.split(' ');
      firstName.value = parts.first;
      lastName.value = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    } else {
      if (first != null && first.isNotEmpty) firstName.value = first;
      if (last != null && last.isNotEmpty) lastName.value = last;
      name.value = '$firstName $lastName'.trim();
    }

    if (emailAddress != null && emailAddress.isNotEmpty) email.value = emailAddress;
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) dob.value = dateOfBirth;
    if (userGender != null && userGender.isNotEmpty) gender.value = userGender;
    if (userMaritalStatus != null && userMaritalStatus.isNotEmpty) maritalStatus.value = userMaritalStatus;
    if (addr != null && addr.isNotEmpty) address.value = addr;
    if (addrType != null && addrType.isNotEmpty) addressType.value = addrType;

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
    } catch (e) {
      isLoggingOut.value = false;
      await SessionManager.clearSession();
    }
  }
}
