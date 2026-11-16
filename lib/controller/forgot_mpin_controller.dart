import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/otp_verification_controller.dart';
import '../screens/otp_verification_screen.dart';

/// GetX controller for "Forgot MPIN" screen.
/// Uses direct reactive observable variable binding (no addListener needed).
class ForgotMpinController extends GetxController {
  final mobileNumber = ''.obs;
  final mobileController = TextEditingController();

  bool get canSubmit => mobileNumber.value.trim().length == 10;

  void onMobileChanged(String val) {
    mobileNumber.value = val;
  }

  @override
  void onClose() {
    mobileController.dispose();
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
