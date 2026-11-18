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

  bool get has4Digits => newMpin.value.length == 4;

  bool get hasNoSequence {
    final pin = newMpin.value;
    if (pin.length < 2) return true;
    const sequences = [
      '0123', '1234', '2345', '3456', '4567', '5678', '6789',
      '3210', '4321', '5432', '6543', '7654', '8765', '9876',
    ];
    for (final seq in sequences) {
      if (pin == seq) return false;
    }
    return true;
  }

  bool get hasNoRepeats {
    final pin = newMpin.value;
    if (pin.length < 2) return true;
    if (pin.length == 4 &&
        pin[0] == pin[1] &&
        pin[1] == pin[2] &&
        pin[2] == pin[3]) {
      return false;
    }
    return true;
  }

  bool get isMpinValid => has4Digits && hasNoSequence && hasNoRepeats;
  bool get isMpinConfirmed =>
      confirmMpin.value.length == 4 && confirmMpin.value == newMpin.value;
  bool get canSetMpin => isMpinValid && isMpinConfirmed;

  void selectMpinField(String field) {
    activeMpinField.value = field;
  }

  void enterMpinDigit(String digit) {
    if (activeMpinField.value == 'new') {
      if (newMpin.value.length < 4) {
        newMpin.value += digit;
        if (newMpin.value.length == 4) {
          activeMpinField.value = 'confirm';
        }
      }
    } else {
      if (confirmMpin.value.length < 4) {
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
