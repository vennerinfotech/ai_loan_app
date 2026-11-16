import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// GetX controller for "Forgot MPIN" screen.
class ForgotMpinController extends GetxController {
  final mobileNumber = ''.obs;
  final mobileController = TextEditingController();
  final focusNode = FocusNode();
  final isFocused = false.obs;

  bool get canSubmit => mobileNumber.value.trim().length == 10;

  @override
  void onInit() {
    super.onInit();
    mobileController.addListener(() {
      mobileNumber.value = mobileController.text;
    });

    focusNode.addListener(() {
      isFocused.value = focusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    mobileController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void sendOtp() {
    if (!canSubmit) return;
    Get.snackbar(
      'Reset Code Sent',
      'A verification code has been sent to +91 ${mobileNumber.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF212074),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void backToLogin() {
    Get.back();
  }
}
