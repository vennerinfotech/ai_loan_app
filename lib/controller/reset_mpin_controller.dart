import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../screens/login_with_mpin_screen.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../services/biometric_service.dart';
import '../models/auth_response_model.dart';

/// GetX controller for "Reset MPIN" (Set New MPIN) screen after Forgot MPIN OTP verification.
class ResetMpinController extends GetxController {
  final newMpin = ''.obs;
  final confirmMpin = ''.obs;
  final activeMpinField = 'new'.obs; // 'new' or 'confirm'
  final isSubmitting = false.obs;
  final userPhone = ''.obs;
  final userOtp = ''.obs;

  void setPhoneNumber(String phone) {
    userPhone.value = phone.trim();
  }

  void setOtp(String otp) {
    userOtp.value = otp.trim();
  }

  bool get has6Digits => newMpin.value.length == 6;
  bool get has4Digits => has6Digits;

  bool get hasNoSequence {
    final pin = newMpin.value;
    if (pin.length < 2) return true;
    const sequences = [
      '012345', '123456', '234567', '345678', '456789',
      '543210', '654321', '765432', '876543', '987654',
    ];
    for (final seq in sequences) {
      if (pin == seq) return false;
    }
    return true;
  }

  bool get hasNoRepeats {
    final pin = newMpin.value;
    if (pin.length < 2) return true;
    if (pin.length == 6 && pin.split('').every((c) => c == pin[0])) {
      return false;
    }
    return true;
  }

  bool get isMpinValid => has6Digits && hasNoSequence && hasNoRepeats;
  bool get isMpinConfirmed =>
      confirmMpin.value.length == 6 && confirmMpin.value == newMpin.value;
  bool get canSetMpin => isMpinValid && isMpinConfirmed;

  void selectMpinField(String field) {
    activeMpinField.value = field;
  }

  void enterMpinDigit(String digit) {
    if (activeMpinField.value == 'new') {
      if (newMpin.value.length < 6) {
        newMpin.value += digit;
        if (newMpin.value.length == 6) {
          activeMpinField.value = 'confirm';
        }
      }
    } else {
      if (confirmMpin.value.length < 6) {
        confirmMpin.value += digit;
      }
    }
  }

  void deleteMpinDigit() {
    if (activeMpinField.value == 'confirm') {
      if (confirmMpin.value.isNotEmpty) {
        confirmMpin.value =
            confirmMpin.value.substring(0, confirmMpin.value.length - 1);
      } else {
        activeMpinField.value = 'new';
      }
    } else {
      if (newMpin.value.isNotEmpty) {
        newMpin.value = newMpin.value.substring(0, newMpin.value.length - 1);
      }
    }
  }

  Future<void> setMpin() async {
    if (!canSetMpin || isSubmitting.value) return;

    try {
      isSubmitting.value = true;
      final response = await ApiService.resetMpin(
        phone: userPhone.value,
        otp: userOtp.value,
        mpin: newMpin.value,
        mpinConfirmation: confirmMpin.value,
      );
      isSubmitting.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200 ||
          response['status_code'] == 201;

      if (isSuccess) {
        final model = AuthResponseModel.fromJson(response);
        final token = model.data?.token;
        final name = model.data?.user?.name;
        final phone = model.data?.user?.phone ?? userPhone.value;

        if (token != null && token.isNotEmpty) {
          await SessionManager.saveLoginSession(
            phone: phone,
            name: name,
            token: token,
            userId: model.data?.user?.id,
          );
        }

        // Keep secure Keystore MPIN updated with new MPIN
        await BiometricService.instance.saveStoredMpin(newMpin.value, phone: phone);

        Get.snackbar(
          'Success',
          model.message.isNotEmpty
              ? model.message
              : 'MPIN reset successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
        Get.offAll(() => LoginWithMpinScreen(phoneNumber: phone));
      } else {
        final errorMsg = ApiService.getErrorMessage(response);
        debugPrint('Reset MPIN Error: $errorMsg');
        Get.snackbar(
          'Reset Failed',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isSubmitting.value = false;
      debugPrint('Reset MPIN Exception: $e');
      Get.snackbar(
        'Error',
        'Failed to reset MPIN: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }
}
