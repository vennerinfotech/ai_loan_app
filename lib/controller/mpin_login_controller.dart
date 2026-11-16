import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// GetX controller for Login with MPIN flow.
class MpinLoginController extends GetxController {
  final mpin = ''.obs;
  final userName = 'Aarav Mehta'.obs;
  final userInitials = 'AM'.obs;
  final isSubmitting = false.obs;

  void enterDigit(String digit) {
    if (mpin.value.length < 4) {
      mpin.value += digit;
      if (mpin.value.length == 4) {
        submitLogin();
      }
    }
  }

  void deleteDigit() {
    if (mpin.value.isNotEmpty) {
      mpin.value = mpin.value.substring(0, mpin.value.length - 1);
    }
  }

  void submitLogin() {
    isSubmitting.value = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      isSubmitting.value = false;
      Get.snackbar(
        'Success',
        'Welcome back, ${userName.value}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF212074),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    });
  }

  void triggerBiometric() {
    Get.snackbar(
      'Biometric Login',
      'Authenticating via fingerprint...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF524FBA),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void useMobileNumber() {
    Get.back();
  }

  void forgotMpin() {
    Get.snackbar(
      'Forgot MPIN',
      'OTP sent to your registered mobile number.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E2127),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}
