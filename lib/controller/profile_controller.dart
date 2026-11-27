import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/user_model.dart';
import '../models/applicant_detail_model.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../screens/login_with_mobile_screen.dart';
import '../theme/app_colors.dart';
import 'dashboard_controller.dart';

/// Controller managing user profile data, avatar image, and updates.
/// Exposes [user] ([UserModel]) as the single source of truth across screens.
class ProfileController extends GetxController {
  // Single UserModel instance holding the loaded user profile
  final user = Rxn<UserModel>();

  // Full applicant details strictly from GET /applicants/{user_id} API
  final applicantDetail = Rxn<ApplicantDetailModel>();
  final isLoading = false.obs;

  final isKycDone = false.obs;
  final coApplicantsCount = 0.obs;
  final documentsCount = 0.obs;

  final isSaving = false.obs;
  final isLoggingOut = false.obs;

  // Dynamic field-level validation errors returned by backend API (422 errors map)
  final fieldErrors = <String, String>{}.obs;

  void clearFieldError(String field) {
    if (fieldErrors.containsKey(field)) {
      fieldErrors.remove(field);
    }
  }

  void clearAllFieldErrors() {
    fieldErrors.clear();
  }

  // Saved profile image (local memory bytes)
  final profileImageBytes = Rxn<Uint8List>();
  final profileImagePath = ''.obs;

  // Staged profile image during editing (NOT uploaded until Save button is tapped)
  final tempImageBytes = Rxn<Uint8List>();
  final tempImagePath = ''.obs;

  // Selected language preference
  final selectedLanguage = 'English'.obs;

  // App version loaded from package info
  final appVersion = ''.obs;

  // Direct convenience getters backed by [user.value]
  String get name => user.value?.name ?? '';
  String get fullName => user.value?.name ?? '';
  String get firstName => user.value?.firstName ?? '';
  String get lastName => user.value?.lastName ?? '';
  String get email => user.value?.email ?? '';
  String get phone => user.value?.phone ?? '';
  String get dob => user.value?.dob ?? '';
  String get gender => user.value?.gender ?? '';
  String get maritalStatus => user.value?.maritalStatus ?? '';
  String get address => user.value?.address ?? '';
  String get addressType => user.value?.addressType ?? '';
  String get photoUrl => user.value?.photoUrl ?? '';
  String get employmentType => user.value?.role ?? '';
  String get initials => user.value?.initials ?? '';
  String get maskedPhone => user.value?.maskedPhone ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadCachedSession();
    fetchApplicantProfile();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion.value = 'Version ${info.version}';
    } catch (e) {
      debugPrint('Failed to load app version: $e');
    }
  }

  Future<void> _loadCachedSession() async {
    final savedName = await SessionManager.getUserName();
    final savedPhone = await SessionManager.getUserPhone();
    if (savedName.isNotEmpty || savedPhone.isNotEmpty) {
      user.value = (user.value ?? UserModel()).copyWith(
        name: savedName.isNotEmpty ? savedName : null,
        phone: savedPhone.isNotEmpty ? savedPhone : null,
      );
    }
  }

  /// Fetch full applicant details directly as a typed model via GET /applicants/{user_id}
  Future<void> fetchApplicantProfile({bool isRefresh = false}) async {
    if (!isRefresh) isLoading.value = true;
    try {
      dynamic effectiveUserId;
      final savedId = await SessionManager.getUserId();
      if (savedId.isNotEmpty) {
        effectiveUserId = savedId;
      }
      if ((effectiveUserId == null || effectiveUserId.toString().trim().isEmpty) &&
          Get.isRegistered<DashboardController>()) {
        final dashId = Get.find<DashboardController>().dashboardData.value?.user?.id;
        if (dashId != null) effectiveUserId = dashId;
      }
      effectiveUserId ??= 1;

      final model = await ApiService.getApplicantDetailModel(userId: effectiveUserId);
      if (model != null) {
        applicantDetail.value = model;
        final mappedUser = model.toUserModel();
        if (mappedUser != null) {
          user.value = mappedUser;
          if (mappedUser.id != null) {
            SessionManager.saveUserId(mappedUser.id);
          }
        }

        // Dynamic KYC status
        if (model.summary?.kycCompleted != null) {
          isKycDone.value = model.summary!.kycCompleted!;
        } else if (model.kyc != null) {
          final aadhaarDone = model.kyc!.aadhaar?.status?.toLowerCase() == 'accepted' ||
              model.kyc!.aadhaar?.uploaded == true;
          final panDone = model.kyc!.pan?.status?.toLowerCase() == 'accepted' ||
              model.kyc!.pan?.uploaded == true;
          isKycDone.value = aadhaarDone && panDone;
        }

        // Dynamic co-applicants count
        if (model.summary?.totalCoApplicants != null) {
          coApplicantsCount.value = model.summary!.totalCoApplicants!;
        } else {
          coApplicantsCount.value = model.coApplicants.length;
        }

        // Dynamic documents count
        if (model.summary?.documentsUploaded != null) {
          documentsCount.value = model.summary!.documentsUploaded!;
        } else {
          int count = 0;
          if (model.kyc?.aadhaar?.uploaded == true) count++;
          if (model.kyc?.pan?.uploaded == true) count++;
          documentsCount.value = count;
        }
      }
    } catch (e) {
      debugPrint('Exception in fetchApplicantProfile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setLanguage(String lang) {
    selectedLanguage.value = lang;
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

  /// Updates profile in memory directly on [user]
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
    final resolvedName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : '${first ?? firstName} ${last ?? lastName}'.trim();

    user.value = (user.value ?? UserModel()).copyWith(
      name: resolvedName.isNotEmpty ? resolvedName : null,
      email: (emailAddress != null && emailAddress.isNotEmpty) ? emailAddress : null,
      dob: (dateOfBirth != null && dateOfBirth.isNotEmpty) ? dateOfBirth : null,
      gender: (userGender != null && userGender.isNotEmpty) ? userGender : null,
      maritalStatus: (userMaritalStatus != null && userMaritalStatus.isNotEmpty)
          ? userMaritalStatus
          : null,
      address: (addr != null && addr.isNotEmpty) ? addr : null,
      addressType: (addrType != null && addrType.isNotEmpty) ? addrType : null,
    );

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
    fieldErrors.clear();
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
          user.value = (user.value ?? UserModel()).copyWith(
            photoUrl: photoModel.photoUrl,
          );
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
          user.value = personalModel.user!.copyWith(
            gender: userGender,
            maritalStatus: userMaritalStatus,
            addressType: addrType,
            role: user.value?.role,
          );
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

        // Persist updated user name to session
        await SessionManager.saveLoginSession(name: name);

        // Keep applicant profile data in sync
        fetchApplicantProfile(isRefresh: true);

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
        // Map backend 422 field errors directly so UI renders them inline without snackbars
        if (personalResponse['errors'] is Map) {
          final errMap = personalResponse['errors'] as Map;
          for (final entry in errMap.entries) {
            final key = entry.key.toString();
            final val = entry.value;
            if (val is List && val.isNotEmpty) {
              fieldErrors[key] = val.first.toString().trim();
            } else if (val != null && val.toString().trim().isNotEmpty) {
              fieldErrors[key] = val.toString().trim();
            }
          }
        }

        // Only show snackbar if there are no field-level validation errors
        if (fieldErrors.isEmpty) {
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
        }
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
