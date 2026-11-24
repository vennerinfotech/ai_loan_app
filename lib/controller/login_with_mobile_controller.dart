import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../screens/login_with_mpin_screen.dart';
import '../screens/registration_screen.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

/// GetX controller for "Login with mobile" screen.
/// Uses direct reactive observable variable binding (no addListener needed).
class LoginWithMobileController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final mobileNumber = ''.obs;
  final mobileController = TextEditingController();
  final isLoading = false.obs;

  late final AnimationController orbitController;
  late final Animation<double> orbitAnimation;

  bool get canSubmit => mobileNumber.value.trim().length == 10;

  void onMobileChanged(String val) {
    mobileNumber.value = val;
  }

  @override
  void onInit() {
    super.onInit();
    // Synchronized 24-second continuous loop for hero celestial orbit
    orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    orbitAnimation = CurvedAnimation(
      parent: orbitController,
      curve: Curves.linear,
    );
  }

  @override
  void onClose() {
    orbitController.dispose();
    mobileController.dispose();
    super.onClose();
  }

  /// Check mobile registration via POST /check-mobile-login:
  /// - If is_registered == true: navigate to LoginWithMpinScreen
  /// - If is_registered == false: show message and navigate to RegistrationScreen
  Future<void> getOtp() async {
    if (!canSubmit || isLoading.value) return;
    final phone = mobileNumber.value.trim();

    try {
      isLoading.value = true;
      final response = await ApiService.checkMobileLogin(phone: phone);
      isLoading.value = false;

      final isSuccess =
          response['success'] == true || response['status_code'] == 200;

      if (isSuccess) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : null;
        final isRegistered = data?['is_registered'] == true;

        if (isRegistered) {
          // Returning user: navigate to MPIN Login
          Get.to(() => LoginWithMpinScreen(phoneNumber: phone));
        } else {
          // New user: navigate to Registration
          Get.snackbar(
            'Create Account',
            response['message']?.toString() ??
                'Mobile number not registered. Please register to continue.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.navy,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
          Get.to(() => const RegistrationScreen());
        }
      } else {
        final errorMsg = ApiService.getErrorMessage(response);
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Exception in checkMobileLogin: $e');
      Get.snackbar(
        'Error',
        'Failed to check mobile number: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void signInWithMpin() {
    final phone = mobileNumber.value.trim();
    if (phone.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your 10-digit mobile number to sign in with MPIN',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if (phone.length < 10) {
      Get.snackbar(
        'Invalid Mobile Number',
        'Please enter a valid 10-digit mobile number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    Get.to(
      () => LoginWithMpinScreen(phoneNumber: phone),
    );
  }

  void createAccount() {
    Get.to(() => const RegistrationScreen());
  }
}
