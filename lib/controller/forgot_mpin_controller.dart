import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/otp_verification_controller.dart';
import '../screens/otp_verification_screen.dart';

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
    Get.to(() => OtpVerificationScreen(
          phoneNumber: mobileNumber.value,
          type: OtpVerificationType.forgotMpin,
        ));
  }

  void backToLogin() {
    Get.back();
  }
}
