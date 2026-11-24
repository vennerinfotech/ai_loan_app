import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../screens/login_with_mobile_screen.dart';
import '../theme/app_colors.dart';

/// Controller managing user profile data, avatar image, and updates
class ProfileController extends GetxController {
  // UserModel instance holding the loaded user profile
  final user = Rxn<UserModel>();

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
  final photoUrl = ''.obs;
  final isSaving = false.obs;
  final isLoggingOut = false.obs;

  // Saved profile image (local memory bytes)
  final profileImageBytes = Rxn<Uint8List>();
  final profileImagePath = ''.obs;

  // Staged profile image during editing (NOT uploaded until Save button is tapped)
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

  /// Sets staged image when picked from camera/gallery.
  /// API is NOT called here; only called when user taps Save Changes button.
  void setTempImage(Uint8List bytes, String path) {
    tempImageBytes.value = bytes;
    tempImagePath.value = path;
  }

  /// Clears staged image if user cancels editing
  void clearTempImage() {
    tempImageBytes.value = null;
    tempImagePath.value = '';
  }

  /// Updates profile in memory
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
      clearTempImage();
    }
  }

  /// Calls both update-profile-photo (if staged photo exists) and update-personal-info APIs.
  /// Only invoked when user taps the Save / Update Profile button.
  Future<bool> updateProfileAndPhoto({
    required String fullName,
    required String emailAddress,
    required String dateOfBirth,
    required String userGender,
    required String userMaritalStatus,
    required String addr,
    required String addrType,
  }) async {
    isSaving.value = true;
    try {
      // 1. Upload photo if user staged a new photo during editing
      if (tempImageBytes.value != null || tempImagePath.value.isNotEmpty) {
        final photoResponse = await ApiService.updateProfilePhoto(
          filePath: tempImagePath.value,
          fileBytes: tempImageBytes.value,
        );

        final photoModel =
            UpdateProfilePhotoResponseModel.fromJson(photoResponse);

        if (photoModel.success &&
            photoModel.photoUrl != null &&
            photoModel.photoUrl!.isNotEmpty) {
          photoUrl.value = photoModel.photoUrl!;
          profileImageBytes.value = tempImageBytes.value;
          profileImagePath.value = tempImagePath.value;
          clearTempImage();
        } else {
          final errorMsg = ApiService.getErrorMessage(photoResponse);
          Get.snackbar(
            'Photo Upload Failed',
            errorMsg.isNotEmpty ? errorMsg : 'Could not upload profile photo.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorRed,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          isSaving.value = false;
          return false;
        }
      }

      // 2. Call update-personal-info API
      final personalResponse = await ApiService.updatePersonalInfo(
        name: fullName,
        email: emailAddress,
        dob: dateOfBirth,
        gender: userGender,
        maritalStatus: userMaritalStatus,
        address: addr,
        addressType: addrType,
      );

      final personalModel =
          UpdatePersonalInfoResponseModel.fromJson(personalResponse);

      if (personalModel.success) {
        if (personalModel.user != null) {
          user.value = personalModel.user;
          if (personalModel.user!.name != null &&
              personalModel.user!.name!.isNotEmpty) {
            name.value = personalModel.user!.name!;
            final parts = name.value.split(' ');
            firstName.value = parts.first;
            lastName.value = parts.length > 1 ? parts.sublist(1).join(' ') : '';
          }
          if (personalModel.user!.email != null &&
              personalModel.user!.email!.isNotEmpty) {
            email.value = personalModel.user!.email!;
          }
          if (personalModel.user!.dob != null &&
              personalModel.user!.dob!.isNotEmpty) {
            dob.value = personalModel.user!.dob!;
          }
          if (personalModel.user!.address != null &&
              personalModel.user!.address!.isNotEmpty) {
            address.value = personalModel.user!.address!;
          }
          if (personalModel.user!.phone != null &&
              personalModel.user!.phone!.isNotEmpty) {
            phone.value = personalModel.user!.phone!;
          }
        } else {
          saveProfile(
            fullName: fullName,
            emailAddress: emailAddress,
            dateOfBirth: dateOfBirth,
            userGender: userGender,
            userMaritalStatus: userMaritalStatus,
            addr: addr,
            addrType: addrType,
          );
        }

        gender.value = userGender;
        maritalStatus.value = userMaritalStatus;
        addressType.value = addrType;

        // Persist updated user name to session
        await SessionManager.saveLoginSession(name: name.value);

        Get.snackbar(
          'Success',
          personalModel.message.isNotEmpty
              ? personalModel.message
              : 'Personal information updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

        isSaving.value = false;
        return true;
      } else {
        final errorMsg = ApiService.getErrorMessage(personalResponse);
        Get.snackbar(
          'Update Failed',
          errorMsg.isNotEmpty
              ? errorMsg
              : (personalModel.message.isNotEmpty
                  ? personalModel.message
                  : 'Failed to update personal details.'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        isSaving.value = false;
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in updateProfileAndPhoto: $e');
      }
      Get.snackbar(
        'Error',
        'An unexpected error occurred while updating profile.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorRed,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      isSaving.value = false;
      return false;
    }
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

      // Clean up all controller instances so no old session data persists
      Get.deleteAll(force: true);

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
      if (kDebugMode) {
        print('error => $e');
      }
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      isLoggingOut.value = false;
      await SessionManager.clearSession();
      Get.deleteAll(force: true);
      Get.offAll(() => const LoginWithMobileScreen());
    }
  }
}
