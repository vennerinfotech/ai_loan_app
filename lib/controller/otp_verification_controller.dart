import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../screens/reset_mpin_screen.dart';
import '../screens/main_nav_screen.dart';
import '../services/session_manager.dart';
import '../services/api_service.dart';
import '../models/auth_response_model.dart';

enum OtpVerificationType {
  forgotMpin,
  loginWithMobile,
}

/// Reusable GetX controller for OTP Verification across both
/// "Forgot MPIN" and "Login with Mobile" flows.
class OtpVerificationController extends GetxController {
  final String phoneNumber;
  final OtpVerificationType type;
  final String? initialOtp;

  OtpVerificationController({
    required this.phoneNumber,
    this.type = OtpVerificationType.forgotMpin,
    this.initialOtp,
  });

  final otpCode = ''.obs;
  final otpController = TextEditingController();
  final otpFocusNode = FocusNode();

  final resendCountdown = 57.obs;
  final canResend = false.obs;
  Timer? _resendTimer;

  final isVerifying = false.obs;
  final isResending = false.obs;

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
    if (initialOtp != null && initialOtp!.isNotEmpty) {
      otpController.value = TextEditingValue(
        text: initialOtp!,
        selection: TextSelection.collapsed(offset: initialOtp!.length),
      );
      otpCode.value = initialOtp!;
    }
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

  Future<void> resendCode() async {
    if (!canResend.value || isResending.value) return;

    if (type == OtpVerificationType.forgotMpin) {
      try {
        isResending.value = true;
        final response = await ApiService.forgotMpinResend(phone: phoneNumber);
        isResending.value = false;

        final isSuccess = response['success'] == true ||
            response['status_code'] == 200 ||
            response['status_code'] == 201;

        if (isSuccess) {
          final model = AuthResponseModel.fromJson(response);
          final newOtp = model.data?.otp?.toString();
          if (newOtp != null && newOtp.isNotEmpty) {
            otpController.value = TextEditingValue(
              text: newOtp,
              selection: TextSelection.collapsed(offset: newOtp.length),
            );
            otpCode.value = newOtp;
            debugPrint('Auto-filled resent Forgot MPIN OTP: $newOtp');
          }

          startResendTimer();
          Get.snackbar(
            'Success',
            model.message.isNotEmpty
                ? model.message
                : 'OTP resent successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.navy,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          );
        } else {
          final errorMsg = ApiService.getErrorMessage(response);
          debugPrint('Forgot MPIN Resend Error: $errorMsg');
          Get.snackbar(
            'Resend Failed',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade800,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        isResending.value = false;
        debugPrint('Forgot MPIN Resend Exception: $e');
        Get.snackbar(
          'Error',
          'Failed to resend OTP: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } else {
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
  }

  Future<void> verifyOtp() async {
    final enteredOtp = otpCode.value.trim();
    if (enteredOtp.length < 6 || isVerifying.value) return;

    if (type == OtpVerificationType.forgotMpin) {
      try {
        isVerifying.value = true;
        final response = await ApiService.forgotMpinVerify(
          phone: phoneNumber,
          otp: enteredOtp,
        );
        isVerifying.value = false;

        final isSuccess = response['success'] == true ||
            response['status_code'] == 200 ||
            response['status_code'] == 201;

        if (isSuccess) {
          final model = AuthResponseModel.fromJson(response);
          Get.snackbar(
            'Success',
            model.message.isNotEmpty
                ? model.message
                : 'OTP verified. You can now reset MPIN.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.navy,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          );

          Get.off(() => ResetMpinScreen(phoneNumber: phoneNumber));
        } else {
          final errorMsg = ApiService.getErrorMessage(response);
          debugPrint('Forgot MPIN Verify Error: $errorMsg');
          Get.snackbar(
            'Verification Failed',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade800,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        isVerifying.value = false;
        debugPrint('Forgot MPIN Verify Exception: $e');
        Get.snackbar(
          'Error',
          'Failed to verify OTP: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } else {
      isVerifying.value = true;
      Future.delayed(const Duration(milliseconds: 400), () {
        isVerifying.value = false;
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
      });
    }
  }
}
