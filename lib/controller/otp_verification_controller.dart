import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../screens/reset_mpin_screen.dart';
import '../screens/main_nav_screen.dart';
import '../services/session_manager.dart';

enum OtpVerificationType {
  forgotMpin,
  loginWithMobile,
}

/// Reusable GetX controller for OTP Verification across both
/// "Forgot MPIN" and "Login with Mobile" flows.
class OtpVerificationController extends GetxController {
  final String phoneNumber;
  final OtpVerificationType type;

  OtpVerificationController({
    required this.phoneNumber,
    this.type = OtpVerificationType.forgotMpin,
  });

  final otpCode = ''.obs;
  final otpController = TextEditingController();
  final otpFocusNode = FocusNode();

  final resendCountdown = 57.obs;
  final canResend = false.obs;
  Timer? _resendTimer;

  final isVerifying = false.obs;

  /// Formatted masked phone: +91 98765 ••••10
  String get maskedPhone {
    final clean = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (clean.length >= 10) {
      return '+91 ${clean.substring(0, 5)} ••••${clean.substring(clean.length - 2)}';
    }
    return '+91 $phoneNumber';
  }

  @override
  void onInit() {
    super.onInit();
    startResendTimer();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    otpController.dispose();
    otpFocusNode.dispose();
    super.onClose();
  }

  void startResendTimer() {
    resendCountdown.value = 57;
    canResend.value = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void onOtpChanged(String val) {
    otpCode.value = val;
  }

  void enterOtpDigit(String digit) {
    if (otpController.text.length < 6) {
      otpController.text += digit;
      otpCode.value = otpController.text;
      if (otpCode.value.length == 6) {
        verifyOtp();
      }
    }
  }

  void deleteOtpDigit() {
    if (otpController.text.isNotEmpty) {
      otpController.text =
          otpController.text.substring(0, otpController.text.length - 1);
      otpCode.value = otpController.text;
    }
  }

  void resendCode() {
    if (!canResend.value) return;
    startResendTimer();
    Get.snackbar(
      'Code Sent',
      'A new 6-digit code has been sent to $maskedPhone',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.navy,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void verifyOtp() {
    if (otpCode.value.length < 6) return;

    isVerifying.value = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      isVerifying.value = false;

      if (type == OtpVerificationType.forgotMpin) {
        Get.off(() => const ResetMpinScreen());
      } else {
        // Save session with setString
        SessionManager.saveLoginSession(phone: phoneNumber);
        Get.snackbar(
          'Login Successful',
          'Welcome to Finsphere AI!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
        Get.offAll(() => const MainNavScreen());
      }
    });
  }
}
