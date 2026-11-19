import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../screens/login_with_mpin_screen.dart';

/// GetX controller for "Reset MPIN" (Set New MPIN) screen after Forgot MPIN OTP verification.
class ResetMpinController extends GetxController {
  final newMpin = ''.obs;
  final confirmMpin = ''.obs;
  final activeMpinField = 'new'.obs; // 'new' or 'confirm'
  final isSubmitting = false.obs;
  final userPhone = ''.obs;

  void setPhoneNumber(String phone) {
    userPhone.value = phone.trim();
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

  void setMpin() {
    if (!canSetMpin) return;

    isSubmitting.value = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      isSubmitting.value = false;
      Get.snackbar(
        'MPIN Updated',
        'Your new MPIN has been set successfully. Please log in.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      Get.offAll(() => const LoginWithMpinScreen());
    });
  }
}
