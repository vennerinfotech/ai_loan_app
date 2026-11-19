import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../controller/otp_verification_controller.dart';
import '../screens/otp_verification_screen.dart';
import '../services/api_service.dart';
import '../models/auth_response_model.dart';
import '../theme/app_colors.dart';

/// GetX controller for "Forgot MPIN" screen.
/// Uses direct reactive observable variable binding (no addListener needed).
class ForgotMpinController extends GetxController {
  final mobileNumber = ''.obs;
  final mobileController = TextEditingController();
  final isSendingOtp = false.obs;
  final authResponse = Rxn<AuthResponseModel>();

  bool get canSubmit => mobileNumber.value.trim().length == 10;

  void onMobileChanged(String val) {
    mobileNumber.value = val;
  }

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }

  /// Send OTP API for Forgot MPIN: POST /forgot-mpin-otp
  Future<void> sendOtp() async {
    if (!canSubmit || isSendingOtp.value) return;

    final phone = mobileNumber.value.trim();

    try {
      isSendingOtp.value = true;
      final response = await ApiService.forgotMpinOtp(phone: phone);
      isSendingOtp.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200 ||
          response['status_code'] == 201;

      if (isSuccess) {
        final model = AuthResponseModel.fromJson(response);
        authResponse.value = model;

        final otp = model.data?.otp?.toString();
        if (otp != null && otp.isNotEmpty) {
          debugPrint('Auto-fill Forgot MPIN OTP: $otp');
        }

        Get.snackbar(
          'Success',
          model.message.isNotEmpty
              ? model.message
              : 'OTP sent to mobile for MPIN reset.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

        Get.to(
          () => OtpVerificationScreen(
            phoneNumber: phone,
            type: OtpVerificationType.forgotMpin,
            initialOtp: otp,
          ),
        );
      } else {
        final errorMsg = ApiService.getErrorMessage(response);
        debugPrint('Forgot MPIN OTP Error: $errorMsg');
        Get.snackbar(
          'Failed',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isSendingOtp.value = false;
      debugPrint('Forgot MPIN OTP Exception: $e');
      Get.snackbar(
        'Error',
        'Failed to send OTP: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void backToLogin() {
    Get.back();
  }
}
