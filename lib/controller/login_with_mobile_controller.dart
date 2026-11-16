import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../screens/login_with_mpin_screen.dart';
import '../screens/registration_screen.dart';

/// GetX controller for "Login with mobile" screen.
class LoginWithMobileController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final mobileNumber = ''.obs;
  final mobileController = TextEditingController();
  final focusNode = FocusNode();
  final isFocused = false.obs;

  late final AnimationController orbitController;
  late final Animation<double> orbitAnimation;

  bool get canSubmit => mobileNumber.value.trim().length == 10;

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

    mobileController.addListener(() {
      mobileNumber.value = mobileController.text;
    });

    focusNode.addListener(() {
      isFocused.value = focusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    orbitController.dispose();
    mobileController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void getOtp() {
    if (!canSubmit) return;
    Get.snackbar(
      'OTP Sent',
      'A 6-digit code has been sent to +91 ${mobileNumber.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF212074),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void signInWithMpin() {
    Get.to(() => const LoginWithMpinScreen());
  }

  void createAccount() {
    Get.to(() => const RegistrationScreen());
  }
}
