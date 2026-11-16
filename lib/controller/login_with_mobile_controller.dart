import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/otp_verification_controller.dart';
import '../screens/login_with_mpin_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/registration_screen.dart';

/// GetX controller for "Login with mobile" screen.
/// Uses direct reactive observable variable binding (no addListener needed).
class LoginWithMobileController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final mobileNumber = ''.obs;
  final mobileController = TextEditingController();

  late final AnimationController orbitController;
  late final Animation<double> orbitAnimation;

  bool get canSubmit => mobileNumber.value.trim().length == 10;

  void onMobileChanged(String val) {
    mobileNumber.value = val;
  }

  @override
  void onInit() {
    super.onInit();
    // Synchronized 24-second continuous loop for hero celestial orbit
    orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    orbitAnimation = CurvedAnimation(
      parent: orbitController,
      curve: Curves.linear,
    );
  }

  @override
  void onClose() {
    orbitController.dispose();
    mobileController.dispose();
    super.onClose();
  }

  void getOtp() {
    if (!canSubmit) return;
    Get.to(() => OtpVerificationScreen(
          phoneNumber: mobileNumber.value,
          type: OtpVerificationType.loginWithMobile,
        ));
  }

  void signInWithMpin() {
    Get.to(() => const LoginWithMpinScreen());
  }

  void createAccount() {
    Get.to(() => const RegistrationScreen());
  }
}
